import 'package:flutter_test/flutter_test.dart';
import 'package:vaultx/features/wallet/presentation/card_scanner/card_ocr_parser.dart';

void main() {
  group('CardOcrParser Tests', () {
    test('Correctly extracts Visa card number, expiry, and holder name', () {
      final lines = [
        'CHASE SAPPHIRE',
        '4532 8920 1840 9214',
        'GOOD THRU 08/29',
        'ALEX MORGAN',
      ];
      final fullText = lines.join('\n');

      final result = CardOcrParser.parseLines(
        lines: lines,
        fullText: fullText,
      );

      expect(result.cardNumber, equals('4532892018409214'));
      expect(result.expiry, equals('08/29'));
      expect(result.cardholderName, equals('ALEX MORGAN'));
      expect(result.network, equals('Visa'));
      expect(result.hasDetails, isTrue);
    });

    test('Correctly detects Mastercard network and expiration date', () {
      final lines = [
        'CITI BANK',
        '5412 7512 3412 3456',
        'VALID 12/28',
        'SARAH CONNOR',
      ];
      final fullText = lines.join('\n');

      final result = CardOcrParser.parseLines(
        lines: lines,
        fullText: fullText,
      );

      expect(result.cardNumber, equals('5412751234123456'));
      expect(result.expiry, equals('12/28'));
      expect(result.cardholderName, equals('SARAH CONNOR'));
      expect(result.network, equals('Mastercard'));
    });

    test('Ignores blacklisted words like BANK, DEBIT, VALID THRU as cardholder name', () {
      final lines = [
        'PREMIER BANK DEBIT',
        '4111 1111 1111 1111',
        'EXP 05/27',
        'JOHN SMITH',
      ];
      final fullText = lines.join('\n');

      final result = CardOcrParser.parseLines(
        lines: lines,
        fullText: fullText,
      );

      expect(result.cardNumber, equals('4111111111111111'));
      expect(result.expiry, equals('05/27'));
      expect(result.cardholderName, equals('JOHN SMITH'));
    });
  });
}
