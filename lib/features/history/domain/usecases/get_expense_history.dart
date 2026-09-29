import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../entities/expense_history.dart';
import '../entities/history_filter.dart';

/// Filters and sorts expenses, grouping them by day when sorted by date.
class GetExpenseHistory implements UseCase<ExpenseHistory, HistoryFilter> {
  const GetExpenseHistory(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<ExpenseHistory> call(HistoryFilter filter) async {
    final query = filter.query.trim().toLowerCase();
    final expenses = await _repository.getExpenses();

    final matches = expenses.where((e) {
      if (!filter.includes(e.date)) return false;
      if (filter.categories.isNotEmpty &&
          !filter.categories.contains(e.category)) {
        return false;
      }
      if (query.isEmpty) return true;
      return e.title.toLowerCase().contains(query) ||
          (e.note?.toLowerCase().contains(query) ?? false);
    }).toList();

    switch (filter.sort) {
      case ExpenseSort.newestFirst:
        matches.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSort.oldestFirst:
        matches.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSort.highestAmount:
        matches.sort((a, b) => b.amount.compareTo(a.amount));
        return ExpenseHistory(
          groups: [if (matches.isNotEmpty) ExpenseGroup(expenses: matches)],
        );
    }

    final byDay = <DateTime, List<Expense>>{};
    for (final e in matches) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      byDay.putIfAbsent(day, () => []).add(e);
    }
    return ExpenseHistory(
      groups: [
        for (final entry in byDay.entries)
          ExpenseGroup(date: entry.key, expenses: entry.value),
      ],
    );
  }
}
