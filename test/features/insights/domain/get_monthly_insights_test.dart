import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';
import 'package:expenses_tracking_app/features/insights/domain/usecases/get_monthly_insights.dart';

import '../../../fakes/in_memory_category_data_source.dart';
import '../../../fakes/in_memory_dashboard_data_source.dart';
import '../../../fakes/in_memory_expense_data_source.dart';

void main() {
  final now = DateTime(2026, 9, 27, 20);
  DateTime clock() => now;

  late ExpenseRepositoryImpl expenses;
  late GetMonthlyInsights getInsights;

  setUp(() {
    expenses = ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: clock),
      CategoryRepositoryImpl(InMemoryCategoryDataSource()),
    );
    getInsights = GetMonthlyInsights(
      DashboardRepositoryImpl(
        InMemoryDashboardDataSource(),
        expenses,
        clock: clock,
      ),
      expenses,
      clock: clock,
    );
  });

  test('totals, budget and days left for the current month', () async {
    final insights = await getInsights(DateTime(2026, 9));

    expect(insights.totalSpent, 84250);
    expect(insights.budgetLeft, 40750);
    expect(insights.daysLeft, 3);
    expect(insights.changeVsPreviousMonth!.round(), -12);
    expect(insights.expenseCount, 16);
  });

  test('category shares are sorted and add up to exactly 100', () async {
    final insights = await getInsights(DateTime(2026, 9));

    expect(insights.categories.map((c) => c.category), [
      ExpenseCategory.food,
      ExpenseCategory.bills,
      ExpenseCategory.transport,
      ExpenseCategory.shopping,
      ExpenseCategory.health,
      ExpenseCategory.leisure,
    ]);
    expect(insights.categories.map((c) => c.percent), [34, 22, 20, 14, 6, 4]);
    expect(insights.categories.fold(0, (s, c) => s + c.percent), 100);
  });

  test('more than 6 categories fold the smallest into Other', () async {
    await expenses.saveExpense(
      Expense(
        id: '',
        title: 'Stamps',
        amount: 100,
        category: ExpenseCategory.other,
        date: DateTime(2026, 9, 20),
      ),
    );
    final insights = await getInsights(DateTime(2026, 9));

    expect(insights.categories.length, 6);
    expect(insights.categories.last.category, ExpenseCategory.other);
    // Leisure (3,300) + Other (100) folded together.
    expect(insights.categories.last.amount, 3400);
  });

  test('weeks run in 7-day blocks up to today', () async {
    final insights = await getInsights(DateTime(2026, 9));

    expect(insights.weeks.map((w) => '${w.startDay}-${w.endDay}'), [
      '1-7',
      '8-14',
      '15-21',
      '22-27',
    ]);
    expect(insights.weeks.fold<double>(0, (s, w) => s + w.amount), 84250);
  });

  test('a past month covers every day and has no days left', () async {
    final insights = await getInsights(DateTime(2026, 8));

    expect(insights.daysLeft, isNull);
    expect(insights.weeks.last.endDay, 31);
    expect(insights.weeks.length, 5);
    expect(insights.totalSpent, 95740);
  });
}
