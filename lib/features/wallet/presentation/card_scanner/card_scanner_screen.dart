import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vaultx/core/theme/app_theme.dart';
import 'package:vaultx/features/wallet/presentation/add_card_screen.dart';
import 'package:vaultx/features/wallet/presentation/card_scanner/card_ocr_parser.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  String _statusMessage = 'Align card inside the frame';
  Timer? _autoScanTimer;

  late AnimationController _animController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _statusMessage = 'No camera found on this device.';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });

      // Start periodic auto-scanning every 1.5 seconds
      _startAutoScan();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Unable to access camera: $e';
        });
      }
    }
  }

  void _startAutoScan() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!_isProcessing && mounted && _isCameraInitialized) {
        _captureAndAnalyze();
      }
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) {
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final xFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(xFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final result = CardOcrParser.parse(recognizedText);

      if (!mounted) return;

      if (result.cardNumber.isNotEmpty) {
        _handleScanSuccess(result);
      } else {
        setState(() {
          _statusMessage = 'Looking for card numbers...';
          _isProcessing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleScanSuccess(CardScanResult result) {
    _autoScanTimer?.cancel();
    HapticFeedback.heavyImpact();

    // Format display number
    final formattedNum = _formatCardNumber(result.cardNumber);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.emerald500,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Card Scanned: $formattedNum',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AddCardScreen(
          initialTitle: result.cardholderName.isNotEmpty ? '${result.cardholderName}\'s Card' : '${result.network} Card',
          initialNumber: result.cardNumber,
          initialExpiry: result.expiry,
          initialHolder: result.cardholderName.isNotEmpty ? result.cardholderName : 'CARDHOLDER',
          initialNetwork: result.network,
        ),
      ),
    );
  }

  String _formatCardNumber(String value) {
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final newMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newMode);
      setState(() => _isTorchOn = !_isTorchOn);
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void _openManualEntry() {
    _autoScanTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const AddCardScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _animController.dispose();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.85;
    final cardHeight = cardWidth / 1.586; // Standard ISO/IEC 7810 ID-1 card ratio

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview or Placeholder
          if (_isCameraInitialized && _cameraController != null)
            Center(
              child: CameraPreview(_cameraController!),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        _handleScanSuccess(
                          const CardScanResult(
                            cardNumber: '4532892018409214',
                            expiry: '08/29',
                            cardholderName: 'JANE DOE',
                            network: 'Visa',
                            hasDetails: true,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.credit_card_rounded, size: 18),
                      label: const Text('Simulate Card Detection'),
                    ),
                  ],
                ),
              ),
            ),

          // 2. Translucent Cutout Backdrop
          Positioned.fill(
            child: CustomPaint(
              painter: _CardViewfinderOverlayPainter(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
              ),
            ),
          ),

          // 3. Card Viewfinder Target Frame with Animated Scanning Line
          Center(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                children: [
                  // Corner brackets
                  ...[
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ].map((alignment) {
                    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
                    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
                    return Align(
                      alignment: alignment,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CustomPaint(
                          painter: _ScannerCornerPainter(
                            isLeft: isLeft,
                            isTop: isTop,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Subtle EMV Chip watermark indicator
                  Positioned(
                    left: 20,
                    top: cardHeight * 0.35,
                    child: Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                    ),
                  ),

                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: cardHeight * _scanLineAnimation.value,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue.withAlpha(20),
                                AppColors.primaryBlue,
                                AppColors.primaryBlue.withAlpha(20),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withAlpha(160),
                                blurRadius: 10,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Top App Bar / Controls
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Text(
                      'Scan Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _toggleTorch,
                      style: IconButton.styleFrom(
                        backgroundColor: _isTorchOn ? AppColors.primaryBlue : Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
                      tooltip: 'Toggle Flash',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Controls & Instructions
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isProcessing)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryBlue,
                              ),
                            )
                          else
                            const Icon(
                              Icons.credit_card_rounded,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Shutter / Capture Button
                    GestureDetector(
                      onTap: _isProcessing ? null : _captureAndAnalyze,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: AppColors.primaryBlue.withAlpha(220),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withAlpha(120),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Manual Entry Fallback Button
                    TextButton.icon(
                      onPressed: _openManualEntry,
                      icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 16),
                      label: const Text(
                        'Enter Details Manually',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to darken the area outside the card rectangle.
class _CardViewfinderOverlayPainter extends CustomPainter {
  final double cardWidth;
  final double cardHeight;

  const _CardViewfinderOverlayPainter({
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withAlpha(170);

    final left = (size.width - cardWidth) / 2;
    final top = (size.height - cardHeight) / 2;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cardWidth, cardHeight),
      const Radius.circular(16),
    );

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cardPath = Path()..addRRect(cardRect);

    final overlayPath = Path.combine(PathOperation.difference, fullPath, cardPath);
    canvas.drawPath(overlayPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(cardRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CardViewfinderOverlayPainter oldDelegate) {
    return oldDelegate.cardWidth != cardWidth || oldDelegate.cardHeight != cardHeight;
  }
}

class _ScannerCornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;

  const _ScannerCornerPainter({
    required this.isLeft,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isLeft && isTop) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (!isLeft && isTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isLeft && !isTop) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
