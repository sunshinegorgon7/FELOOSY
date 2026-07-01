import '../../data/models/sms_rule.dart';

class SmsParserService {
  // ISO 4217 codes covering every major currency worldwide, plus regional
  // shorthands commonly found in local bank SMS.
  //
  // Shorthands by country/region:
  //   UAE      → AED or Dh/Dhs    KSA     → SAR or SR
  //   Kuwait   → KWD or KD        Bahrain → BHD or BD
  //   Jordan   → JOD or JD        Egypt   → EGP or LE
  //   India    → INR or Rs./Rs    Pakistan→ PKR or Rs./Rs
  //   Kenya    → KES or KSh       Nigeria → NGN or ₦
  //   S.Africa → ZAR              Malaysia→ MYR or RM
  //   Indonesia→ IDR or Rp        B'desh  → BDT or Tk
  //   Turkey   → TRY or TL        Brazil  → BRL or R$
  //   Philippines → PHP or ₱
  static const _currencyCodes =
      // Middle East & North Africa
      r'EGP|AED|USD|EUR|GBP|SAR|KWD|QAR|BHD|OMR|JOD|MAD|TND|LBP|IQD|DZD|LYD|SYP|YER'
      // South Asia
      r'|INR|PKR|BDT|LKR|NPR'
      // Sub-Saharan Africa
      r'|KES|NGN|ZAR|GHS|TZS|UGX|RWF|XOF|XAF|ETB|MWK|ZMW'
      // Southeast Asia & East Asia
      r'|PHP|MYR|THB|IDR|SGD|VND|MMK|KHR|JPY|KRW|CNY|HKD|TWD'
      // Americas
      r'|CAD|MXN|BRL|ARS|COP|CLP|PEN|UYU'
      // Oceania
      r'|AUD|NZD'
      // Europe (non-EUR)
      r'|CHF|SEK|NOK|DKK|PLN|CZK|HUF|TRY|RON|BGN|HRK|RSD|UAH|RUB|GEL'
      // Regional shorthands (case-insensitive matching)
      r'|LE|SR|KD|BD|JD|Dhs?|Rs\.?|KSh|RM|Rp|Tk|TL|R\$';

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
  // Covers global bank SMS formats including:
  //   UAE/GCC  → "Trx. of", "Payment of", "spent", "charged"
  //   India    → "debited", "txn", "txn amt", "A/c debited"
  //   Africa   → M-Pesa "Confirmed" + amount, "bought", "Withdraw"
  //   SE Asia  → GCash/GrabPay "You have paid", "You have sent"
  //   LatAm    → "compra", "pago", "cobro", "débito"
  //   Europe   → "Zahlung", "paiement", "pagamento", "betaling"
  //   Turkey   → "harcama", "ödeme", "işlem"
  //   Arabic   → "خصم", "سحب", "شراء", "دفع"
  static final _transactionVerbPattern = RegExp(
    // English verbs — core
    r'\b(debited?|credited?|spent|paid|payment\s+of|charged|deducted|withdrawn'
    r'|purchase[d]?|refund(?:ed)?|settled|processed|reversed|approved'
    // English abbreviations
    r'|trx\.?\s+of|txn\.?\s*(?:of|amt|alert)?|transaction|trans\.?\s+amt'
    // DR/CR shorthand (bank statements: "DR 500", "CR 200")
    r'|(?:DR|CR)(?=\s*[\d,])'
    // English action phrases
    r'|payment\s+received|payment\s+made|payment\s+sent'
    r'|bill\s+payment|auto[\s\-]?pay|direct\s+debit|standing\s+order'
    r'|cash\s+(?:withdrawal|advance)|pos\s+(?:purchase|txn|trx|transaction)'
    r'|atm\s+(?:withdrawal|w/?d)|card\s+(?:payment|charge|txn|transaction)'
    r'|online\s+(?:payment|purchase|txn)|e[\s\-]?commerce'
    // M-Pesa / mobile money (East Africa)
    r'|confirmed\.?\s+[\w\d]+\s+(?:Ksh|KES|UGX|TZS)'
    r'|bought\s+(?:airtime|data|goods)'
    // Spanish
    r'|compra(?:\s+con)?|pago|cobro|d[eé]bito|cargo|retiro|transferencia'
    // Portuguese (Brazil)
    r'|compra\s+(?:no|aprovada)|pagamento|d[eé]bito|saque'
    // French
    r'|paiement|achat|d[eé]bit[eé]?|retrait|pr[eé]l[eè]vement'
    // German
    r'|zahlung|abbuchung|lastschrift|kartenzahlung|auszahlung'
    // Turkish
    r'|harcama|[oö]deme|i[sş]lem|kartla\s+[oö]deme|nakit\s+[cç]ekim'
    // Arabic (bank SMS in MENA)
    r'|خصم|سحب|شراء|دفع|عملية|مبلغ)\b',
    caseSensitive: false,
  );

  // Negative gate: bank-to-bank / peer-to-peer transfer signals.
  static final _transferExclusionPattern = RegExp(
    r'\b(NEFT|IMPS|RTGS|SWIFT|UPI|SEPA|ACH|EFT|IBAN'
    r'|transfer(?:red)?\s+to|to\s+(?:a\/c|account|card|mobile)|sent\s+to'
    r'|wire\s+transfer|fund\s+transfer|bank\s+transfer'
    r'|transferencia\s+a|virement|[uü]berweisung)\b',
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
