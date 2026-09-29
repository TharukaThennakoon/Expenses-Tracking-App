import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';
import 'package:expenses_tracking_app/features/expenses/domain/usecases/save_expense.dart';

import '../../../fakes/in_memory_category_data_source.dart';
import '../../../fakes/in_memory_expense_data_source.dart';

void main() {
  late ExpenseRepositoryImpl repository;
  late SaveExpense save;

  final draft = Expense(
    id: '',
    title: '  Lunch with team ',
    amount: 2450,
    category: ExpenseCategory.food,
    date: DateTime(2026, 9, 27, 13),
    note: '   ',
  );

  setUp(() {
    repository = ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: () => DateTime(2026, 9, 27, 20)),
      CategoryRepositoryImpl(InMemoryCategoryDataSource()),
    );
    save = SaveExpense(repository);
  });

  test('creates a new expense with an id and tidied fields', () async {
    final saved = await save(draft);

    expect(saved.id, isNotEmpty);
    expect(saved.title, 'Lunch with team');
    expect(saved.note, isNull);
    expect(
      (await repository.getExpenses()).map((e) => e.id),
      contains(saved.id),
    );
  });

  test('updates an existing expense in place', () async {
    final saved = await save(draft);
    final before = (await repository.getExpenses()).length;

    await save(saved.copyWith(amount: 3000));

    final all = await repository.getExpenses();
    expect(all.length, before);
    expect(all.firstWhere((e) => e.id == saved.id).amount, 3000);
  });

  test('rejects invalid expenses', () {
    expect(() => save(draft.copyWith(amount: 0)), throwsArgumentError);
    expect(() => save(draft.copyWith(title: ' ')), throwsArgumentError);
  });
}
