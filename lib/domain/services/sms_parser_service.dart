import '../../data/models/sms_rule.dart';

class SmsParserService {
  // Full ISO codes first, then regional shorthands used in local bank SMS.
  //
  // Shorthands by country:
  //   UAE     → AED or Dh/Dhs (e.g. "Dhs 1,500.00")
  //   KSA     → SAR or SR (e.g. "SR 250.00")
  //   Kuwait  → KWD or KD  (e.g. "KD 25.000" — 3 d.p. / fils)
  //   Bahrain → BHD or BD  (e.g. "BD 12.500" — 3 d.p. / fils)
  //   Jordan  → JOD or JD  (e.g. "JD 45.000" — 3 d.p. / fils)
  //   Egypt   → EGP or LE  (e.g. "LE 500", "LE500.00")
  //   India   → INR or Rs./Rs (e.g. "Rs 5,000.00")
  //   Pakistan→ PKR or Rs./Rs (overlaps INR — context-dependent)
  //
  // Note: MAD (Morocco) sometimes appears as "DH" or "Dhs" locally, but those
  // shorthands collide with UAE usage, so we rely on MAD here.
  static const _currencyCodes =
      r'EGP|AED|USD|EUR|GBP|SAR|KWD|QAR|BHD|OMR|JOD|MAD|TND|LBP|IQD|INR|PKR'
      r'|LE|SR|KD|BD|JD|Dhs?|Rs\.?';

  // Amounts may carry commas as thousands separators (e.g. "16,000.00").
  // Decimal part is 1–3 digits: KWD, BHD, JOD, TND denominate to 3 d.p. (fils).
  static const _amountPattern = r'[\d,]+(?:\.\d{1,3})?';

  /// Extracts the most prominent monetary amount from an SMS body.
  ///
  /// Tries the custom regex first if provided, then built-in patterns in order:
  ///   1. CURRENCY AMOUNT  (e.g. "EGP 150.00", "AED 16,000.00", "KD 25.000")
  ///   2. AMOUNT CURRENCY  (e.g. "150.00 EGP", "1,500.000 KWD", "250AED")
  ///   3. Fallback: any decimal number with exactly 2 d.p. (e.g. "150.00")
  ///
  /// Pass [requireCurrencyCode] = true to skip the fallback pattern (3) and
  /// only accept amounts explicitly paired with a recognised currency code.
  /// Use this when bulk-scanning historical SMS to avoid false positives from
  /// timestamps, reference numbers, and other incidental decimal values.
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

    // Pattern 1: CURRENCY AMOUNT
    // Covers: "AED 50.00", "AED50.00", "AED 16,000.00", "AED16,000.00",
    //         "AED16000.00", "AED 160000.00", "KD 25.000", "LE500", "SR 1,250"
    final p1 = RegExp(
      '(?:$_currencyCodes)\\s*($_amountPattern)',
      caseSensitive: false,
    );
    final m1 = p1.firstMatch(body);
    if (m1 != null) {
      return double.tryParse(m1.group(1)!.replaceAll(',', ''));
    }

    // Pattern 2: AMOUNT CURRENCY
    // Covers: "150.00 EGP", "1,500.000 KWD", "250AED", "5,000 Rs."
    // (?!\w) prevents matching currency code mid-word (e.g. "SAED" won't grab "AED")
    final p2 = RegExp(
      '($_amountPattern)\\s*(?:$_currencyCodes)(?!\\w)',
      caseSensitive: false,
    );
    final m2 = p2.firstMatch(body);
    if (m2 != null) {
      return double.tryParse(m2.group(1)!.replaceAll(',', ''));
    }

    // Pattern 3: Fallback — any decimal with exactly 2 d.p.
    // Skipped when requireCurrencyCode = true to avoid matching timestamps
    // (e.g. "9.30 PM"), OTP codes, or other incidental decimal values.
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
  /// (case-insensitive). Normalises whitespace before matching so that
  /// multi-word keywords like "HAWA ELSHAM" are not broken by double spaces,
  /// non-breaking spaces, or other Unicode whitespace variants in SMS bodies.
  static SmsRule? matchRule(String body, List<SmsRule> rules) {
    final lower = body.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    for (final rule in rules) {
      final keyword = rule.keyword.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (lower.contains(keyword)) return rule;
    }
    return null;
  }

  // Compiled once. Matches the "at VENDOR" construct found in bank transaction
  // SMS across UAE/GCC/EGY/IND banks. Vendor terminates at: comma, the words
  // "on"/"using"/"is" (word-boundary), or a period followed by whitespace/EOL.
  static final _vendorAtPattern = RegExp(
    r"(?:^|\s)at\s+([A-Za-z0-9][A-Za-z0-9 &\-'.]{1,49}?)(?:\s*,|\s+on\b|\s+using\b|\s+is\b|\s*\.(?:\s|$)|\s*$)",
    caseSensitive: false,
  );

  /// Extracts the merchant/vendor name from a bank transaction SMS body.
  ///
  /// Returns null when no "at VENDOR" pattern is found — caller should fall
  /// back to the SMS sender name in that case.
  static String? extractVendor(String body) {
    final match = _vendorAtPattern.firstMatch(body);
    return match?.group(1)?.trim();
  }

  // ── looksLikeTransaction filter ───────────────────────────────────────────
  //
  // Used only in the suggestion algorithm to reduce false positives from
  // transfers, balance alerts, salary credits, and OTP messages.
  //
  // Positive gate: must contain at least one debit/credit/purchase verb.
  static final _transactionVerbPattern = RegExp(
    r'\b(debited?|credited?|spent|paid|payment\s+of|charged|deducted|withdrawn|purchase[d]?|trx\.?\s+of|transaction)\b',
    caseSensitive: false,
  );

  // Negative gate: bank-to-bank transfer signals.
  // "sent to" is included because peer-to-peer UPI/mobile transfers say
  // "Rs X sent to 9876@ybl" — not a merchant purchase worth a rule.
  static final _transferExclusionPattern = RegExp(
    r'\b(NEFT|IMPS|RTGS|SWIFT|transfer(?:red)?\s+to|to\s+(?:a\/c|account|card|mobile)|sent\s+to)\b',
    caseSensitive: false,
  );

  // Negative gate: salary/income — user prefers not to create rules for these.
  static final _salaryExclusionPattern = RegExp(
    r'\b(salary|income|payroll|stipend|pay\s*slip)\b',
    caseSensitive: false,
  );

  // Negative gate: OTP and security messages (usually already filtered by
  // the AD- sender prefix, but some banks send OTPs from their normal sender).
  static final _otpExclusionPattern = RegExp(
    r'\b(OTP|one.time\s+pass(?:word|code)?|passcode|verification\s+code|authentication\s+code)\b',
    caseSensitive: false,
  );

  /// Returns true only if [body] looks like a merchant debit/credit event
  /// worth suggesting a rule for. Filters out transfers, salary credits,
  /// balance alerts, and OTP messages.
  static bool looksLikeTransaction(String body) {
    if (!_transactionVerbPattern.hasMatch(body)) return false;
    if (_transferExclusionPattern.hasMatch(body)) return false;
    if (_salaryExclusionPattern.hasMatch(body)) return false;
    if (_otpExclusionPattern.hasMatch(body)) return false;
    return true;
  }
}
