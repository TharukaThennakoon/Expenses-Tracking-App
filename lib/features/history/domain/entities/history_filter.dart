import '../../../expenses/domain/entities/expense_category.dart';

enum DateRangePreset { thisMonth, lastMonth, last3Months, custom }

enum ExpenseSort { newestFirst, oldestFirst, highestAmount }

class HistoryFilter {
  const HistoryFilter({
    required this.from,
    required this.to,
    this.preset = DateRangePreset.custom,
    this.query = '',
    this.categories = const {},
    this.sort = ExpenseSort.newestFirst,
  });

  /// Default filter: this month, all categories, newest first.
  factory HistoryFilter.initial(DateTime now) => HistoryFilter(
    from: now,
    to: now,
  ).withPreset(DateRangePreset.thisMonth, now);

  /// First day included (date only).
  final DateTime from;

  /// Last day included (date only).
  final DateTime to;

  /// Which preset produced [from]/[to]; [DateRangePreset.custom] if picked.
  final DateRangePreset preset;

  /// Matched against title and note (case-insensitive).
  final String query;

  /// Empty means all categories.
  final Set<ExpenseCategory> categories;

  final ExpenseSort sort;

  /// Number of filters that differ from the defaults (search excluded).
  int get activeCount =>
      categories.length +
      (preset == DateRangePreset.thisMonth ? 0 : 1) +
      (sort == ExpenseSort.newestFirst ? 0 : 1);

  bool includes(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(from) && !day.isAfter(to);
  }

  /// Applies [preset] relative to [now]. Custom keeps the current range.
  HistoryFilter withPreset(DateRangePreset preset, DateTime now) {
    final (from, to) = switch (preset) {
      DateRangePreset.thisMonth => (
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1, 0),
      ),
      DateRangePreset.lastMonth => (
        DateTime(now.year, now.month - 1),
        DateTime(now.year, now.month, 0),
      ),
      DateRangePreset.last3Months => (
        DateTime(now.year, now.month - 2),
        DateTime(now.year, now.month + 1, 0),
      ),
      DateRangePreset.custom => (this.from, this.to),
    };
    return copyWith(from: from, to: to, preset: preset);
  }

  /// Sets a custom range, keeping it ordered.
  HistoryFilter withCustomRange({DateTime? from, DateTime? to}) {
    var start = _dateOnly(from ?? this.from);
    var end = _dateOnly(to ?? this.to);
    if (start.isAfter(end)) {
      // Move the other bound so the range stays valid.
      from != null ? end = start : start = end;
    }
    return copyWith(from: start, to: end, preset: DateRangePreset.custom);
  }

  HistoryFilter copyWith({
    DateTime? from,
    DateTime? to,
    DateRangePreset? preset,
    String? query,
    Set<ExpenseCategory>? categories,
    ExpenseSort? sort,
  }) => HistoryFilter(
    from: from ?? this.from,
    to: to ?? this.to,
    preset: preset ?? this.preset,
    query: query ?? this.query,
    categories: categories ?? this.categories,
    sort: sort ?? this.sort,
  );

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
