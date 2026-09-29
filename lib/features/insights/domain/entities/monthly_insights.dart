import '../../../expenses/domain/entities/expense_category.dart';

/// One slice of the month's spending.
class CategoryShare {
  const CategoryShare({
    required this.category,
    required this.amount,
    required this.percent,
  });

  final ExpenseCategory category;
  final double amount;

  /// Whole-number percentage; all shares of a month add up to 100.
  final int percent;
}

/// Spending for a run of days within the month, e.g. the 8th to the 14th.
class WeeklySpend {
  const WeeklySpend({
    required this.startDay,
    required this.endDay,
    required this.amount,
  });

  final int startDay;
  final int endDay;
  final double amount;
}

class MonthlyInsights {
  const MonthlyInsights({
    required this.month,
    required this.totalSpent,
    required this.previousMonthSpent,
    this.budget,
    required this.expenseCount,
    required this.categories,
    required this.weeks,
    this.daysLeft,
  });

  /// First day of the month.
  final DateTime month;
  final double totalSpent;
  final double previousMonthSpent;

  /// Null when no budget is set.
  final double? budget;
  final int expenseCount;

  /// Largest first, at most [maxSegments] (the rest folded into "Other").
  final List<CategoryShare> categories;

  /// Consecutive 7-day blocks from the 1st, up to today for the current month.
  final List<WeeklySpend> weeks;

  /// Days remaining after today; null when the month isn't the current one.
  final int? daysLeft;

  static const int maxSegments = 6;

  bool get hasBudget => budget != null && budget! > 0;

  /// Zero when there is no budget.
  double get budgetLeft => hasBudget ? budget! - totalSpent : 0;

  bool get isOverBudget => hasBudget && totalSpent > budget!;

  bool get isEmpty => expenseCount == 0;

  /// Percentage change vs the previous month; null with nothing to compare.
  double? get changeVsPreviousMonth => previousMonthSpent <= 0
      ? null
      : (totalSpent - previousMonthSpent) / previousMonthSpent * 100;
}
