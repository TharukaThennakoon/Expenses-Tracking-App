import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/core/utils/amount_input_formatter.dart';
import 'package:expenses_tracking_app/core/utils/formatters.dart';

void main() {
  const formatter = AmountInputFormatter();

  String type(String old, String next) => formatter
      .formatEditUpdate(
        TextEditingValue(text: old),
        TextEditingValue(text: next),
      )
      .text;

  test('groups thousands while typing', () {
    expect(type('245', '2450'), '2,450');
    expect(type('2,450', '2,450.5'), '2,450.5');
    expect(type('', '1234567'), '1,234,567');
  });

  test('rejects invalid input', () {
    expect(type('2,450.50', '2,450.505'), '2,450.50'); // 3 decimals
    expect(type('2.5', '2.5.'), '2.5'); // second dot
    expect(type('12', '12a'), '12');
  });

  test('normalises leading zeros and dots', () {
    expect(type('', '.'), '0.');
    expect(type('0', '05'), '5');
  });

  test('parses formatted text', () {
    expect(AmountInputFormatter.parse('2,450.50'), 2450.5);
    expect(AmountInputFormatter.parse(''), isNull);
  });

  test('amount formatting never shows 3-digit cents', () {
    expect(Formatters.amount(12.999), '13.00');
    expect(Formatters.decimalPart(12.999), '.00');
  });
}
