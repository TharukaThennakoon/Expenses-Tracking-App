import 'package:flutter/widgets.dart';

import 'currency.dart';

/// App-wide display currency. Changing it relabels amounts; it does not
/// convert them.
class CurrencyController extends ChangeNotifier {
  Currency _currency = Currency.fallback;

  Currency get currency => _currency;

  // TODO: persist the choice so it survives an app restart.
  void setCurrency(Currency currency) {
    if (currency == _currency) return;
    _currency = currency;
    notifyListeners();
  }
}

/// Makes the [CurrencyController] available below it, rebuilding dependents
/// when the currency changes.
class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    super.key,
    required CurrencyController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The active currency, or [Currency.fallback] outside a scope.
  static Currency of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CurrencyScope>()
          ?.notifier
          ?.currency ??
      Currency.fallback;
}

extension CurrencyContext on BuildContext {
  /// Code of the active currency, e.g. "LKR".
  String get currency => CurrencyScope.of(this).code;
}
