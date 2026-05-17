import 'package:intl/intl.dart';

class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.numberFormatLocale,
    this.searchTerms = const [],
  });

  final String code;
  final String symbol;
  final String name;

  /// Locale used for grouping/decimals (e.g. `de_DE` → 1.234.567,89).
  final String numberFormatLocale;
  final List<String> searchTerms;

  String get displayLabel => '$symbol · $code';
  String get listSubtitle => name;

  String get formatExample =>
      NumberFormat('#,##0.00', numberFormatLocale).format(1234567.89);

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final haystack = [
      code,
      name,
      symbol,
      numberFormatLocale,
      formatExample,
      ...searchTerms,
    ].join(' ').toLowerCase();

    return haystack.contains(q);
  }
}

class AppCurrencyRegistry {
  AppCurrencyRegistry._();

  static const defaultCode = 'USD';

  static const List<AppCurrency> all = [
    AppCurrency(
      code: 'USD',
      symbol: r'$',
      name: 'US Dollar',
      numberFormatLocale: 'en_US',
    ),
    AppCurrency(
      code: 'PKR',
      symbol: '₨',
      name: 'Pakistani Rupee',
      numberFormatLocale: 'en_PK',
      searchTerms: ['pakistan', 'pakistani', 'rupee'],
    ),
    AppCurrency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      numberFormatLocale: 'en_IN',
      searchTerms: ['india', 'indian'],
    ),
    AppCurrency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      numberFormatLocale: 'de_DE',
      searchTerms: ['europe', 'germany', 'eurozone'],
    ),
    AppCurrency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      numberFormatLocale: 'en_GB',
    ),
    AppCurrency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      numberFormatLocale: 'ja_JP',
    ),
    AppCurrency(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      numberFormatLocale: 'zh_CN',
    ),
    AppCurrency(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      numberFormatLocale: 'ar_AE',
    ),
    AppCurrency(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      numberFormatLocale: 'ar_SA',
    ),
    AppCurrency(
      code: 'CAD',
      symbol: r'$',
      name: 'Canadian Dollar',
      numberFormatLocale: 'en_CA',
    ),
    AppCurrency(
      code: 'AUD',
      symbol: r'A$',
      name: 'Australian Dollar',
      numberFormatLocale: 'en_AU',
    ),
    AppCurrency(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      numberFormatLocale: 'de_CH',
    ),
    AppCurrency(
      code: 'SEK',
      symbol: 'kr',
      name: 'Swedish Krona',
      numberFormatLocale: 'sv_SE',
    ),
    AppCurrency(
      code: 'NOK',
      symbol: 'kr',
      name: 'Norwegian Krone',
      numberFormatLocale: 'nb_NO',
    ),
    AppCurrency(
      code: 'DKK',
      symbol: 'kr',
      name: 'Danish Krone',
      numberFormatLocale: 'da_DK',
    ),
    AppCurrency(
      code: 'PLN',
      symbol: 'zł',
      name: 'Polish Zloty',
      numberFormatLocale: 'pl_PL',
    ),
    AppCurrency(
      code: 'TRY',
      symbol: '₺',
      name: 'Turkish Lira',
      numberFormatLocale: 'tr_TR',
    ),
    AppCurrency(
      code: 'BRL',
      symbol: r'R$',
      name: 'Brazilian Real',
      numberFormatLocale: 'pt_BR',
    ),
    AppCurrency(
      code: 'MXN',
      symbol: r'$',
      name: 'Mexican Peso',
      numberFormatLocale: 'es_MX',
    ),
    AppCurrency(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      numberFormatLocale: 'en_ZA',
    ),
    AppCurrency(
      code: 'SGD',
      symbol: r'S$',
      name: 'Singapore Dollar',
      numberFormatLocale: 'en_SG',
    ),
    AppCurrency(
      code: 'HKD',
      symbol: r'HK$',
      name: 'Hong Kong Dollar',
      numberFormatLocale: 'zh_HK',
    ),
    AppCurrency(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean Won',
      numberFormatLocale: 'ko_KR',
    ),
    AppCurrency(
      code: 'THB',
      symbol: '฿',
      name: 'Thai Baht',
      numberFormatLocale: 'th_TH',
    ),
    AppCurrency(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      numberFormatLocale: 'ms_MY',
    ),
    AppCurrency(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      numberFormatLocale: 'id_ID',
    ),
    AppCurrency(
      code: 'PHP',
      symbol: '₱',
      name: 'Philippine Peso',
      numberFormatLocale: 'en_PH',
    ),
    AppCurrency(
      code: 'NGN',
      symbol: '₦',
      name: 'Nigerian Naira',
      numberFormatLocale: 'en_NG',
    ),
    AppCurrency(
      code: 'EGP',
      symbol: 'E£',
      name: 'Egyptian Pound',
      numberFormatLocale: 'ar_EG',
    ),
    AppCurrency(
      code: 'NZD',
      symbol: r'NZ$',
      name: 'New Zealand Dollar',
      numberFormatLocale: 'en_NZ',
    ),
  ];

  static AppCurrency forCode(String? code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => all.firstWhere((c) => c.code == defaultCode),
    );
  }
}
