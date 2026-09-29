import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/core/usecase/usecase.dart';
import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/usecases/add_sample_data.dart';

import '../../../fakes/in_memory_category_data_source.dart';
import '../../../fakes/in_memory_dashboard_data_source.dart';
import '../../../fakes/in_memory_expense_data_source.dart';

void main() {
  final now = DateTime(2026, 9, 29, 10);
  late ExpenseRepositoryImpl expenses;
  late DashboardRepositoryImpl profiles;
  late AddSampleData addSampleData;

  setUp(() {
    expenses = ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: () => now),
      CategoryRepositoryImpl(InMemoryCategoryDataSource()),
    );
    profiles = DashboardRepositoryImpl(
      InMemoryDashboardDataSource(),
      expenses,
      clock: () => now,
    );
    addSampleData = AddSampleData(expenses, profiles, clock: () => now);
  });

  test('adds this and last month’s expenses, all kept', () async {
    final before = (await expenses.getExpenses()).length;

    final added = await addSampleData(const NoParams());

    final after = await expenses.getExpenses();
    expect(added, 22);
    expect(after, hasLength(before + added));
    expect(
      after.where((e) => e.date.month == 9 && e.title == 'Weekly groceries'),
      hasLength(2), // one from the fake's own data, one added
    );
    expect(after.where((e) => e.date.month == 8), isNotEmpty);
  });

  test('sets a budget only when there is none', () async {
    await profiles.setMonthlyBudget(90000);
    await addSampleData(const NoParams());
    expect((await profiles.getUserProfile()).monthlyBudget, 90000);

    await profiles.setMonthlyBudget(null);
    await addSampleData(const NoParams());
    expect(
      (await profiles.getUserProfile()).monthlyBudget,
      AddSampleData.sampleBudget,
    );
  });
}
