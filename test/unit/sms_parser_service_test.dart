import 'package:flutter_test/flutter_test.dart';

import 'package:feloosy/domain/services/sms_parser_service.dart';

void main() {
  group('isIgnoredSender', () {
    test('ignores the AD- promotional prefix', () {
      expect(SmsParserService.isIgnoredSender('AD-CIB'), isTrue);
      expect(SmsParserService.isIgnoredSender('AD-EmiratesNBD'), isTrue);
    });

    test('is case-insensitive', () {
      expect(SmsParserService.isIgnoredSender('ad-cib'), isTrue);
      expect(SmsParserService.isIgnoredSender('Ad-Cib'), isTrue);
    });

    test('tolerates surrounding whitespace', () {
      expect(SmsParserService.isIgnoredSender('  AD-CIB '), isTrue);
    });

    test('matches non-ASCII dash variants used by some aggregators', () {
      expect(SmsParserService.isIgnoredSender('AD‑CIB'), isTrue);
      expect(SmsParserService.isIgnoredSender('AD–CIB'), isTrue);
    });

    test('does not ignore legitimate bank senders', () {
      for (final sender in [
        'CIB',
        'ADCB', // Abu Dhabi Commercial Bank — starts with "AD" but no dash
        'ADIB',
        'ADIB-Alerts',
        'BankAD-Promo', // prefix only, never mid-string
        'HSBC',
        '+201234567890',
        '',
      ]) {
        expect(
          SmsParserService.isIgnoredSender(sender),
          isFalse,
          reason: 'sender "$sender" should not be treated as promotional',
        );
      }
    });
  });

  group('extractAmount', () {
    test('reads CURRENCY AMOUNT form', () {
      expect(SmsParserService.extractAmount('Purchase of EGP 150.00 at X'), 150.0);
      expect(SmsParserService.extractAmount('AED 16,000.00 debited'), 16000.0);
      expect(SmsParserService.extractAmount('KD 25.000 spent'), 25.0);
    });

    test('reads AMOUNT CURRENCY form', () {
      expect(SmsParserService.extractAmount('150.00 EGP paid'), 150.0);
      expect(SmsParserService.extractAmount('250AED charged'), 250.0);
    });

    test('requireCurrencyCode skips the bare-decimal fallback', () {
      const body = 'Your code expires at 9.30 PM';
      expect(SmsParserService.extractAmount(body), 9.30);
      expect(
        SmsParserService.extractAmount(body, requireCurrencyCode: true),
        isNull,
      );
    });
  });
}
