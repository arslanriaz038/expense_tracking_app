class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  String get displayLabel => '$symbol · $code';
  String get listSubtitle => name;
}

class AppCurrencyRegistry {
  AppCurrencyRegistry._();

  static const defaultCode = 'USD';

  static const List<AppCurrency> all = [
    AppCurrency(code: 'USD', symbol: r'$', name: 'US Dollar'),
    AppCurrency(code: 'EUR', symbol: '€', name: 'Euro'),
    AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound'),
    AppCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    AppCurrency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    AppCurrency(code: 'PKR', symbol: 'Rs', name: 'Pakistani Rupee'),
    AppCurrency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    AppCurrency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    AppCurrency(code: 'CAD', symbol: r'$', name: 'Canadian Dollar'),
    AppCurrency(code: 'AUD', symbol: r'A$', name: 'Australian Dollar'),
    AppCurrency(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
    AppCurrency(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
    AppCurrency(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
    AppCurrency(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
    AppCurrency(code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
    AppCurrency(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
    AppCurrency(code: 'BRL', symbol: r'R$', name: 'Brazilian Real'),
    AppCurrency(code: 'MXN', symbol: r'$', name: 'Mexican Peso'),
    AppCurrency(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
    AppCurrency(code: 'SGD', symbol: r'S$', name: 'Singapore Dollar'),
    AppCurrency(code: 'HKD', symbol: r'HK$', name: 'Hong Kong Dollar'),
    AppCurrency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    AppCurrency(code: 'THB', symbol: '฿', name: 'Thai Baht'),
    AppCurrency(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
    AppCurrency(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
    AppCurrency(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
    AppCurrency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    AppCurrency(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
    AppCurrency(code: 'NZD', symbol: r'NZ$', name: 'New Zealand Dollar'),
  ];

  static AppCurrency forCode(String? code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => all.firstWhere((c) => c.code == defaultCode),
    );
  }
}
