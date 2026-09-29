import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';

import '../../../fakes/in_memory_category_data_source.dart';
import '../../../fakes/in_memory_dashboard_data_source.dart';
import '../../../fakes/in_memory_expense_data_source.dart';

void main() {
  final now = DateTime(2026, 9, 27, 20);
  DateTime clock() => now;

  final repository = DashboardRepositoryImpl(
    InMemoryDashboardDataSource(),
    ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: clock),
      CategoryRepositoryImpl(InMemoryCategoryDataSource()),
    ),
    clock: clock,
  );

  test('builds the current month summary', () async {
    final summary = await repository.getMonthlySummary(DateTime(2026, 9));

    expect(summary.totalSpent, 84250);
    expect(summary.budget, 125000);
    expect(summary.budgetUsedRatio, closeTo(0.674, 0.001));
    expect(summary.averagePerDay.round(), 3120);
    expect(summary.changeVsPreviousMonth!.round(), -12);
    expect(summary.categories.first.category, ExpenseCategory.food);
    expect(summary.categories.first.amount, 28400);
  });

  test('returns the most recent expenses first', () async {
    final recent = await repository.getRecentExpenses(limit: 3);

    expect(recent.map((e) => e.title), [
      'Weekly groceries',
      'Ride to campus',
      'Internet bill',
    ]);
  });
}
