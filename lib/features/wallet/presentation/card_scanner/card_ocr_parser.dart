import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScanResult {
  final String cardNumber;
  final String expiry;
  final String cardholderName;
  final String network;
  final bool hasDetails;

  const CardScanResult({
    this.cardNumber = '',
    this.expiry = '',
    this.cardholderName = '',
    this.network = 'Visa',
    this.hasDetails = false,
  });

  @override
  String toString() {
    return 'CardScanResult(number: $cardNumber, expiry: $expiry, name: $cardholderName, network: $network)';
  }
}

class CardOcrParser {
  static const Set<String> _blacklist = {
    'VISA',
    'MASTERCARD',
    'AMERICAN',
    'EXPRESS',
    'AMEX',
    'DISCOVER',
    'VALID',
    'THRU',
    'FROM',
    'EXPIRES',
    'EXP',
    'MONTH',
    'YEAR',
    'BANK',
    'DEBIT',
    'CREDIT',
    'PLATINUM',
    'SIGNATURE',
    'GOLD',
    'CLASSIC',
    'PREMIER',
    'ELECTRONIC',
    'USE',
    'ONLY',
    'MEMBER',
    'SINCE',
    'SECURITY',
    'CODE',
    'CARD',
    'CHASE',
    'SAPPHIRE',
    'WELLS',
    'FARGO',
    'CITI',
    'CITIBANK',
    'CAPITAL',
    'ONE',
    'BARCLAYS',
    'REVOLUT',
    'MONZO',
    'FEDERAL',
    'UNION',
    'NATIONAL',
    'WORLD',
    'ELITE',
    'PREFERRED',
    'INFINITE',
    'BUSINESS',
  };

  /// Parses raw RecognizedText from Google ML Kit Text Recognition.
  static CardScanResult parse(RecognizedText recognizedText) {
    final fullText = recognizedText.text;
    final allLines = <String>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          allLines.add(text);
        }
      }
    }

    return parseLines(lines: allLines, fullText: fullText);
  }

  /// Parses list of extracted text lines and raw full text.
  static CardScanResult parseLines({
    required List<String> lines,
    required String fullText,
  }) {
    final cardNumber = _extractCardNumber(fullText, lines);
    final expiry = _extractExpiry(fullText, lines);
    final network = _detectNetwork(cardNumber);
    final cardholderName = _extractCardholderName(lines, cardNumber, expiry);

    final hasDetails = cardNumber.isNotEmpty || expiry.isNotEmpty || cardholderName.isNotEmpty;

    return CardScanResult(
      cardNumber: cardNumber,
      expiry: expiry,
      cardholderName: cardholderName,
      network: network,
      hasDetails: hasDetails,
    );
  }

  static String _extractCardNumber(String fullText, List<String> lines) {
    // 1. Try formatted 4x4 or 4-4-4-4 or 15-digit Amex patterns
    final candidateRegex = RegExp(r'\b(?:\d{4}[ -]?){3}\d{4}\b|\b3[47]\d{2}[ -]?\d{6}[ -]?\d{5}\b|\b\d{15,16}\b');

    // First check lines directly
    for (final line in lines) {
      for (final match in candidateRegex.allMatches(line)) {
        final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
        if (_passesLuhn(digits)) {
          return digits;
        }
      }
    }

    // Next check full text
    for (final match in candidateRegex.allMatches(fullText)) {
      final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
      if (_passesLuhn(digits)) {
        return digits;
      }
    }

    // Loose match: any line containing 13-19 consecutive/spaced digits
    for (final line in lines) {
      final digitsOnly = line.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 15 && digitsOnly.length <= 16) {
        if (_passesLuhn(digitsOnly)) {
          return digitsOnly;
        }
      }
    }

    // Fallback: first 15-16 digit sequence found
    for (final match in candidateRegex.allMatches(fullText)) {
      final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 15 && digits.length <= 16) {
        return digits;
      }
    }

    return '';
  }

  static String _extractExpiry(String fullText, List<String> lines) {
    final expRegex = RegExp(r'\b(0[1-9]|1[0-2])[\/\-\.\s](2[4-9]|3[0-9])\b');

    // Check lines containing keywords first
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.contains('THRU') || upper.contains('EXP') || upper.contains('VALID') || upper.contains('/')) {
        final match = expRegex.firstMatch(line);
        if (match != null) {
          return '${match.group(1)}/${match.group(2)}';
        }
      }
    }

    // Check all lines
    for (final line in lines) {
      final match = expRegex.firstMatch(line);
      if (match != null) {
        return '${match.group(1)}/${match.group(2)}';
      }
    }

    // Check entire text
    final match = expRegex.firstMatch(fullText);
    if (match != null) {
      return '${match.group(1)}/${match.group(2)}';
    }

    return '';
  }

  static String _detectNetwork(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith(RegExp(r'^5[1-5]')) || clean.startsWith(RegExp(r'^2(22[1-9]|2[3-9]|[3-6]|7[0-1]|720)'))) {
      return 'Mastercard';
    }
    if (clean.startsWith(RegExp(r'^3[47]'))) return 'Amex';
    return 'Visa';
  }

  static String _extractCardholderName(List<String> lines, String cardNumber, String expiry) {
    final nameRegex = RegExp(r'^[A-Z]{2,}(?:\s+[A-Z]{1,})+$');

    for (final line in lines.reversed) {
      final trimmed = line.trim().toUpperCase();

      // Skip lines containing card numbers or expiry
      if (trimmed.contains(expiry) || (cardNumber.isNotEmpty && trimmed.replaceAll(' ', '').contains(cardNumber))) {
        continue;
      }

      // Check if it has numbers
      if (RegExp(r'\d').hasMatch(trimmed)) continue;

      // Split into words
      final words = trimmed.split(RegExp(r'\s+'));
      if (words.length < 2 || words.length > 4) continue;

      // Check if all words are uppercase letters
      if (!nameRegex.hasMatch(trimmed)) continue;

      // Check if any word is in the blacklist
      bool isBlacklisted = false;
      for (final word in words) {
        if (_blacklist.contains(word)) {
          isBlacklisted = true;
          break;
        }
      }

      if (!isBlacklisted && trimmed.length >= 4) {
        return trimmed;
      }
    }

    return '';
  }

  static bool _passesLuhn(String number) {
    if (number.length < 13 || number.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.tryParse(number[i]) ?? -1;
      if (n == -1) return false;
      if (alternate) {
        n *= 2;
        if (n > 9) n = (n % 10) + 1;
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }
}
