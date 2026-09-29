import 'dart:math' as math;

import '../../../../core/usecase/usecase.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../entities/monthly_insights.dart';

/// Builds the Insights view of one month: totals, budget, category shares
/// and 7-day spending blocks.
class GetMonthlyInsights implements UseCase<MonthlyInsights, DateTime> {
  GetMonthlyInsights(
    this._dashboardRepository,
    this._expenseRepository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DashboardRepository _dashboardRepository;
  final ExpenseRepository _expenseRepository;
  final DateTime Function() _clock;

  @override
  Future<MonthlyInsights> call(DateTime month) async {
    month = DateTime(month.year, month.month);
    final summary = await _dashboardRepository.getMonthlySummary(month);
    final expenses = (await _expenseRepository.getExpenses())
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();

    final now = _clock();
    final isCurrent = now.year == month.year && now.month == month.month;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastDay = isCurrent ? now.day : daysInMonth;

    // 7-day blocks: 1–7, 8–14, … up to the last day we have.
    final weeks = <WeeklySpend>[];
    for (var start = 1; start <= lastDay; start += 7) {
      final end = math.min(start + 6, lastDay);
      final amount = expenses
          .where((e) => e.date.day >= start && e.date.day <= end)
          .fold<double>(0, (sum, e) => sum + e.amount);
      weeks.add(WeeklySpend(startDay: start, endDay: end, amount: amount));
    }

    return MonthlyInsights(
      month: month,
      totalSpent: summary.totalSpent,
      previousMonthSpent: summary.previousMonthSpent,
      budget: summary.budget,
      expenseCount: expenses.length,
      categories: _shares({
        for (final c in summary.categories) c.category: c.amount,
      }),
      weeks: weeks,
      daysLeft: isCurrent ? daysInMonth - now.day : null,
    );
  }

  /// Largest first; beyond [MonthlyInsights.maxSegments] the smallest are
  /// folded into "Other". Percentages use largest-remainder rounding so
  /// they always add up to exactly 100.
  static List<CategoryShare> _shares(Map<ExpenseCategory, double> totals) {
    var entries = totals.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.length > MonthlyInsights.maxSegments) {
      final keep = entries
          .where((e) => e.key != ExpenseCategory.other)
          .take(MonthlyInsights.maxSegments - 1)
          .toList();
      final kept = keep.map((e) => e.key).toSet();
      final otherAmount = entries
          .where((e) => !kept.contains(e.key))
          .fold<double>(0, (sum, e) => sum + e.value);
      entries = [...keep, MapEntry(ExpenseCategory.other, otherAmount)]
        ..sort((a, b) => b.value.compareTo(a.value));
    }

    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    if (total <= 0) return const [];

    final exact = [for (final e in entries) e.value / total * 100];
    final percents = [for (final p in exact) p.floor()];
    var remaining = 100 - percents.fold(0, (a, b) => a + b);
    final byRemainder = List.generate(exact.length, (i) => i)
      ..sort(
        (a, b) => (exact[b] - percents[b]).compareTo(exact[a] - percents[a]),
      );
    for (final i in byRemainder) {
      if (remaining-- <= 0) break;
      percents[i]++;
    }

    return [
      for (var i = 0; i < entries.length; i++)
        CategoryShare(
          category: entries[i].key,
          amount: entries[i].value,
          percent: percents[i],
        ),
    ];
  }
}
