import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/core/utils/formatters.dart';

void main() {
  test('formats amounts with thousands separators', () {
    expect(Formatters.wholeAmount(84250), '84,250');
    expect(Formatters.wholeAmount(125000), '125,000');
    expect(Formatters.wholeAmount(950), '950');
    expect(Formatters.amount(6480), '6,480.00');
    expect(Formatters.decimalPart(12.5), '.50');
  });

  test('formats relative days', () {
    final now = DateTime(2026, 9, 27, 20);
    expect(Formatters.relativeDay(DateTime(2026, 9, 27, 8), now: now), 'Today');
    expect(
      Formatters.relativeDay(DateTime(2026, 9, 26), now: now),
      'Yesterday',
    );
    expect(Formatters.relativeDay(DateTime(2026, 9, 12), now: now), '12 Sep');
  });
}
