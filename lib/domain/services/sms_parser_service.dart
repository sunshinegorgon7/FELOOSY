import '../../data/models/sms_rule.dart';

class SmsParserService {
  // Currency codes common across MENA + international
  static const _currencyCodes =
      r'EGP|AED|USD|EUR|GBP|SAR|KWD|QAR|BHD|OMR|JOD|MAD|TND|LBP|IQD|INR|PKR|LE';

  // Amount pattern: optional thousands separator, optional decimal
  static const _amountPattern = r'[\d,]+(?:\.\d{1,2})?';

  /// Extracts the most prominent monetary amount from an SMS body.
  ///
  /// Tries the custom regex first if provided, then built-in patterns in order:
  ///   1. CURRENCY AMOUNT  (e.g. "EGP 150.00", "AED250")
  ///   2. AMOUNT CURRENCY  (e.g. "150.00 EGP", "250AED")
  ///   3. Fallback: any decimal number with exactly 2 d.p. (e.g. "150.00")
  ///
  /// Pass [requireCurrencyCode] = true to skip the fallback pattern (3) and
  /// only accept amounts that are explicitly paired with a recognised currency
  /// code. Use this when bulk-scanning historical SMS to avoid false positives
  /// from timestamps, reference numbers, and other incidental decimal values.
  static double? extractAmount(
    String body, {
    String? customRegex,
    bool requireCurrencyCode = false,
  }) {
    if (customRegex != null && customRegex.isNotEmpty) {
      try {
        final match = RegExp(customRegex).firstMatch(body);
        if (match != null) {
          final raw = (match.groupCount >= 1 ? match.group(1) : match.group(0))
              ?.replaceAll(',', '');
          return double.tryParse(raw ?? '');
        }
      } catch (_) {
        // fall through to built-in patterns
      }
    }

    // Pattern 1: CURRENCY AMOUNT  (e.g. "EGP 150.00", "AED250")
    final p1 = RegExp(
      '(?:$_currencyCodes)\\s*($_amountPattern)',
      caseSensitive: false,
    );
    final m1 = p1.firstMatch(body);
    if (m1 != null) {
      return double.tryParse(m1.group(1)!.replaceAll(',', ''));
    }

    // Pattern 2: AMOUNT CURRENCY  (e.g. "150.00 EGP", "250AED")
    final p2 = RegExp(
      '($_amountPattern)\\s*(?:$_currencyCodes)(?:\\s|\$)',
      caseSensitive: false,
    );
    final m2 = p2.firstMatch(body);
    if (m2 != null) {
      return double.tryParse(m2.group(1)!.replaceAll(',', ''));
    }

    // Pattern 3: Fallback — any decimal number with exactly 2 d.p.
    // Skipped when requireCurrencyCode is true to prevent false positives from
    // timestamps (e.g. "9.30 PM"), reference codes, or other casual numbers.
    if (!requireCurrencyCode) {
      final p3 = RegExp(r'\b([\d,]+\.\d{2})\b');
      final m3 = p3.firstMatch(body);
      if (m3 != null) {
        return double.tryParse(m3.group(1)!.replaceAll(',', ''));
      }
    }

    return null;
  }

  /// Returns the first active rule whose keyword appears in [body]
  /// (case-insensitive). Returns null if no rule matches.
  static SmsRule? matchRule(String body, List<SmsRule> rules) {
    final lower = body.toLowerCase();
    for (final rule in rules) {
      if (lower.contains(rule.keyword.toLowerCase())) return rule;
    }
    return null;
  }
}
