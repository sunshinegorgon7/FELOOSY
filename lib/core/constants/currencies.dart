class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  final bool symbolLeading;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    required this.symbolLeading,
  });
}

const List<CurrencyOption> kCurrencies = [
  // Gulf — prominent because AED is the default
  CurrencyOption(code: 'AED', symbol: 'AED', name: 'UAE Dirham', symbolLeading: false),
  CurrencyOption(code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal', symbolLeading: false),
  CurrencyOption(code: 'QAR', symbol: 'QAR', name: 'Qatari Riyal', symbolLeading: false),
  CurrencyOption(code: 'KWD', symbol: 'KWD', name: 'Kuwaiti Dinar', symbolLeading: false),
  CurrencyOption(code: 'BHD', symbol: 'BHD', name: 'Bahraini Dinar', symbolLeading: false),
  CurrencyOption(code: 'OMR', symbol: 'OMR', name: 'Omani Rial', symbolLeading: false),
  CurrencyOption(code: 'JOD', symbol: 'JOD', name: 'Jordanian Dinar', symbolLeading: false),
  CurrencyOption(code: 'EGP', symbol: 'EGP', name: 'Egyptian Pound', symbolLeading: false),
  // Major world
  CurrencyOption(code: 'USD', symbol: r'$', name: 'US Dollar', symbolLeading: true),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro', symbolLeading: false),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound', symbolLeading: true),
  CurrencyOption(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', symbolLeading: true),
  CurrencyOption(code: 'CAD', symbol: r'CA$', name: 'Canadian Dollar', symbolLeading: true),
  CurrencyOption(code: 'AUD', symbol: r'A$', name: 'Australian Dollar', symbolLeading: true),
  // South Asia
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee', symbolLeading: true),
  CurrencyOption(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee', symbolLeading: true),
  CurrencyOption(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', symbolLeading: true),
  CurrencyOption(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee', symbolLeading: true),
  // East Asia
  CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen', symbolLeading: true),
  CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', symbolLeading: true),
  CurrencyOption(code: 'KRW', symbol: '₩', name: 'South Korean Won', symbolLeading: true),
];
