import 'package:flutter/services.dart';

import 'formatters.dart';

/// Formats money as it's typed: "2450.5" -> "2,450.5".
/// Allows at most one decimal point and two decimal places.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter({this.maxIntegerDigits = 9});

  final int maxIntegerDigits;

  static final RegExp _valid = RegExp(r'^\d*\.?\d{0,2}$');

  /// "2,450.50" -> 2450.5 (null if empty or invalid).
  static double? parse(String text) =>
      double.tryParse(text.replaceAll(',', ''));

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return const TextEditingValue();
    if (!_valid.hasMatch(raw)) return oldValue;
    if (raw.startsWith('.')) raw = '0$raw';

    final dot = raw.indexOf('.');
    final integer = (dot == -1 ? raw : raw.substring(0, dot)).replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    );
    if (integer.length > maxIntegerDigits) return oldValue;

    final text =
        Formatters.groupDigits(integer) + (dot == -1 ? '' : raw.substring(dot));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
