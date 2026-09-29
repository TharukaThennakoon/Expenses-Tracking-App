/// A currency the user can pick. Amounts are shown as "`code` 1,234.00".
class Currency {
  const Currency(this.code, this.name);

  /// ISO 4217 code, e.g. "LKR".
  final String code;
  final String name;

  static const Currency fallback = Currency('LKR', 'Sri Lankan rupee');

  /// Choices offered in Settings. All use two decimal places, which is what
  /// the amount formatters assume.
  static const List<Currency> supported = [
    fallback,
    Currency('USD', 'US dollar'),
    Currency('EUR', 'Euro'),
    Currency('GBP', 'British pound'),
    Currency('INR', 'Indian rupee'),
    Currency('AUD', 'Australian dollar'),
    Currency('CAD', 'Canadian dollar'),
    Currency('SGD', 'Singapore dollar'),
    Currency('AED', 'UAE dirham'),
  ];

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
