import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/categories/domain/usecases/category_usecases.dart';
import 'package:expenses_tracking_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expenses_tracking_app/features/dashboard/domain/usecases/budget_usecases.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';

import '../../fakes/in_memory_category_data_source.dart';
import '../../fakes/in_memory_dashboard_data_source.dart';
import '../../fakes/in_memory_expense_data_source.dart';

void main() {
  final now = DateTime(2026, 9, 27, 20);
  late CategoryRepositoryImpl categories;
  late ExpenseRepositoryImpl expenses;

  const rent = ExpenseCategory(
    id: '',
    label: '  Rent ',
    iconKey: 'home',
    colorKey: 'purple',
  );

  setUp(() {
    categories = CategoryRepositoryImpl(InMemoryCategoryDataSource());
    expenses = ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: () => now),
      categories,
    );
  });

  group('AddCategory', () {
    test('saves a trimmed category before "Other"', () async {
      final added = await AddCategory(categories)(rent);

      expect(added.id, isNotEmpty);
      expect(added.label, 'Rent');
      final all = await categories.getCategories();
      expect(all.map((c) => c.label).skip(all.length - 2), ['Rent', 'Other']);
    });

    test('rejects empty and duplicate names', () async {
      final existing = ExpenseCategory.defaults;
      expect(AddCategory.validateLabel('   ', existing), 'Name is required');
      expect(
        AddCategory.validateLabel('fOOd', existing),
        'You already have "fOOd"',
      );
      expect(AddCategory.validateLabel('x' * 21, existing), isNotNull);

      await expectLater(
        AddCategory(categories)(
          const ExpenseCategory(
            id: '',
            label: 'Food',
            iconKey: 'home',
            colorKey: 'grey',
          ),
        ),
        throwsA(isA<CategoryValidationException>()),
      );
    });
  });

  group('DeleteCategory', () {
    test('moves its expenses to Other, then removes it', () async {
      final foodBefore = (await expenses.getExpenses())
          .where((e) => e.category == ExpenseCategory.food)
          .map((e) => e.id)
          .toSet();
      expect(foodBefore, isNotEmpty);

      await DeleteCategory(categories, expenses)(ExpenseCategory.food);

      expect(
        await categories.getCategories(),
        isNot(contains(ExpenseCategory.food)),
      );
      final after = await expenses.getExpenses();
      expect(after.where((e) => e.category == ExpenseCategory.food), isEmpty);
      expect(
        after.where((e) => foodBefore.contains(e.id)).map((e) => e.category),
        everyElement(ExpenseCategory.other),
      );
    });

    test('refuses to delete Other', () {
      expect(
        () => DeleteCategory(categories, expenses)(ExpenseCategory.other),
        throwsArgumentError,
      );
    });
  });

  group('SetMonthlyBudget', () {
    test('changes and removes the budget used by the summary', () async {
      final dashboard = DashboardRepositoryImpl(
        InMemoryDashboardDataSource(),
        expenses,
        clock: () => now,
      );
      final month = DateTime(2026, 9);

      await SetMonthlyBudget(dashboard)(90000);
      expect((await dashboard.getMonthlySummary(month)).budget, 90000);

      await SetMonthlyBudget(dashboard)(null);
      final summary = await dashboard.getMonthlySummary(month);
      expect(summary.hasBudget, isFalse);
      expect(summary.budgetUsedRatio, 0);

      expect(() => SetMonthlyBudget(dashboard)(0), throwsArgumentError);
    });
  });
}
