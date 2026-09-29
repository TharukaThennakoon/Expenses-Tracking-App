import '../models/expense_model.dart';

abstract interface class ExpenseDataSource {
  Future<List<ExpenseModel>> getExpenses();

  /// Inserts, or replaces the expense with the same id. An empty id gets a
  /// new one. Returns the stored expense.
  Future<ExpenseModel> saveExpense(ExpenseModel expense);

  Future<void> deleteExpense(String id);

  /// Moves every expense in category [fromId] to [toId].
  Future<void> reassignCategory(String fromId, String toId);

  Stream<void> get changes;
}
