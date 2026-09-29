abstract final class Formatters {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// 84250 -> "84,250"
  static String wholeAmount(double amount) =>
      '${amount < 0 ? '-' : ''}${groupDigits(amount.truncate().abs().toString())}';

  /// "1234567" -> "1,234,567"
  static String groupDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 84250.5 -> ".50"
  static String decimalPart(double amount) =>
      '.${((amount.abs() * 100).round() % 100).toString().padLeft(2, '0')}';

  /// 6480 -> "6,480.00"
  static String amount(double amount) {
    final cents = (amount.abs() * 100).round();
    return '${amount < 0 ? '-' : ''}${groupDigits('${cents ~/ 100}')}'
        '.${(cents % 100).toString().padLeft(2, '0')}';
  }

  /// "10:42 AM"
  static String time12h(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  /// "Sun 27 Sep 2026"
  static String weekdayDayMonthYear(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${dayMonthYear(date)}';

  /// "September 2026"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// "September"
  static String monthName(DateTime date) => _months[date.month - 1];

  /// "Aug"
  static String shortMonth(DateTime date) =>
      _months[date.month - 1].substring(0, 3);

  /// "1 Sep"
  static String dayMonth(DateTime date) => '${date.day} ${shortMonth(date)}';

  /// "1 Sep 2026"
  static String dayMonthYear(DateTime date) => '${dayMonth(date)} ${date.year}';

  /// "Sun, 27 Sep"
  static String weekdayDayMonth(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} ${shortMonth(date)}';

  /// "Today", "Yesterday" or "12 Sep"
  static String relativeDay(DateTime date, {DateTime? now}) {
    return switch (daysAgo(date, now: now)) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => '${date.day} ${shortMonth(date)}',
    };
  }

  /// Whole calendar days between [date] and today (DST-safe).
  static int daysAgo(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(date.year, date.month, date.day)).inDays;
  }

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', //
  ];
}
