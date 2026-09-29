import 'category_spending.dart';

class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.totalSpent,
    this.budget,
    required this.previousMonthSpent,
    required this.daysCounted,
    required this.categories,
  });

  /// First day of the month this summary covers.
  final DateTime month;
  final double totalSpent;

  /// Null when no budget is set.
  final double? budget;
  final double previousMonthSpent;

  /// Days used to compute the daily average (days elapsed for the
  /// current month, full length for past months).
  final int daysCounted;

  /// Sorted from highest to lowest spend.
  final List<CategorySpending> categories;

  bool get hasBudget => budget != null && budget! > 0;

  double get budgetUsedRatio =>
      hasBudget ? (totalSpent / budget!).clamp(0, 1).toDouble() : 0;

  double get averagePerDay => daysCounted <= 0 ? 0 : totalSpent / daysCounted;

  /// Percentage change vs previous month. Negative means spending went down.
  /// Null when there is nothing to compare against.
  double? get changeVsPreviousMonth => previousMonthSpent <= 0
      ? null
      : (totalSpent - previousMonthSpent) / previousMonthSpent * 100;
}
