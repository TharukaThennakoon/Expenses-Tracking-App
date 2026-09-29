import 'package:flutter_test/flutter_test.dart';

import 'package:expenses_tracking_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';
import 'package:expenses_tracking_app/features/history/domain/entities/history_filter.dart';
import 'package:expenses_tracking_app/features/history/domain/usecases/get_expense_history.dart';

import '../../../fakes/in_memory_category_data_source.dart';
import '../../../fakes/in_memory_expense_data_source.dart';

void main() {
  final now = DateTime(2026, 9, 27, 20);
  late ExpenseRepositoryImpl repository;
  late GetExpenseHistory getHistory;
  final thisMonth = HistoryFilter.initial(now);

  setUp(() {
    repository = ExpenseRepositoryImpl(
      InMemoryExpenseDataSource(clock: () => now),
      CategoryRepositoryImpl(InMemoryCategoryDataSource()),
    );
    getHistory = GetExpenseHistory(repository);
  });

  test('initial filter covers the whole current month', () {
    expect(thisMonth.from, DateTime(2026, 9, 1));
    expect(thisMonth.to, DateTime(2026, 9, 30));
    expect(thisMonth.activeCount, 0);
  });

  test('groups the month by day, newest first, with day totals', () async {
    final history = await getHistory(thisMonth);

    expect(history.total, 84250);
    expect(history.groups[0].date, DateTime(2026, 9, 27));
    expect(history.groups[0].total, 7730);
    expect(history.groups[1].date, DateTime(2026, 9, 26));
    expect(history.groups[1].expenses.map((e) => e.title), [
      'Internet bill',
      'Movie night',
    ]);
    expect(history.groups[1].total, 6390);
    expect(history.groups[2].date, DateTime(2026, 9, 24));
  });

  test('filters by category', () async {
    final history = await getHistory(
      thisMonth.copyWith(
        categories: {ExpenseCategory.food, ExpenseCategory.transport},
      ),
    );

    final all = history.groups.expand((g) => g.expenses);
    expect(
      all.every(
        (e) =>
            e.category == ExpenseCategory.food ||
            e.category == ExpenseCategory.transport,
      ),
      isTrue,
    );
    expect(history.total, 28400 + 16850);
  });

  test('date presets and custom ranges', () async {
    final lastMonth = await getHistory(
      thisMonth.withPreset(DateRangePreset.lastMonth, now),
    );
    expect(lastMonth.total, 95740);

    final threeMonths = await getHistory(
      thisMonth.withPreset(DateRangePreset.last3Months, now),
    );
    expect(threeMonths.total, 84250 + 95740);

    final lastTwoDays = await getHistory(
      thisMonth.withCustomRange(
        from: DateTime(2026, 9, 26),
        to: DateTime(2026, 9, 27),
      ),
    );
    expect(lastTwoDays.total, 7730 + 6390);
  });

  test('custom range stays ordered when bounds cross', () {
    final f = thisMonth.withCustomRange(from: DateTime(2026, 10, 5));
    expect(f.from, DateTime(2026, 10, 5));
    expect(f.to, DateTime(2026, 10, 5));
    expect(f.preset, DateRangePreset.custom);
  });

  test('sorts oldest first and by highest amount', () async {
    final oldest = await getHistory(
      thisMonth.copyWith(sort: ExpenseSort.oldestFirst),
    );
    expect(
      oldest.groups.first.date!.isBefore(oldest.groups.last.date!),
      isTrue,
    );

    final byAmount = await getHistory(
      thisMonth.copyWith(sort: ExpenseSort.highestAmount),
    );
    expect(byAmount.groups.single.date, isNull);
    final amounts = byAmount.groups.single.expenses.map((e) => e.amount);
    expect(amounts.first, 9600);
    expect(amounts.toList(), [...amounts]..sort((a, b) => b.compareTo(a)));
  });

  test('searches title and note, case-insensitively', () async {
    final byNote = await getHistory(thisMonth.copyWith(query: 'FIBRE'));
    expect(byNote.groups.single.expenses.single.title, 'Internet bill');

    final byTitle = await getHistory(thisMonth.copyWith(query: 'movie'));
    expect(byTitle.count, 1);
  });

  test('reflects deletions and restores', () async {
    final first = (await getHistory(thisMonth)).groups.first.expenses.first;

    await repository.deleteExpense(first.id);
    expect((await getHistory(thisMonth)).total, 84250 - first.amount);

    await repository.saveExpense(first);
    expect((await getHistory(thisMonth)).total, 84250);
  });
}
