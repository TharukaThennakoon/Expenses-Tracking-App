import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  /// All expenses, newest first.
  Future<List<Expense>> getExpenses();

  /// Inserts a new expense (empty id) or replaces the one with the same id.
  /// Returns the stored expense, including its id.
  Future<Expense> saveExpense(Expense expense);

  Future<void> deleteExpense(String id);

  /// Moves every expense in category [fromId] to [toId].
  Future<void> reassignCategory(String fromId, String toId);

  /// Emits whenever expenses are added, changed or removed.
  Stream<void> watchChanges();
}
