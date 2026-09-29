import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Creates a new expense (empty id) or updates an existing one.
class SaveExpense implements UseCase<Expense, Expense> {
  const SaveExpense(this._repository);

  static const int maxNoteLength = 200;

  final ExpenseRepository _repository;

  @override
  Future<Expense> call(Expense expense) {
    if (expense.amount <= 0) {
      throw ArgumentError.value(expense.amount, 'amount', 'Must be positive');
    }
    if (expense.title.trim().isEmpty) {
      throw ArgumentError.value(expense.title, 'title', 'Must not be empty');
    }
    final note = expense.note?.trim();
    if (note != null && note.length > maxNoteLength) {
      throw ArgumentError.value(note, 'note', 'Too long');
    }
    return _repository.saveExpense(
      expense.copyWith(
        title: expense.title.trim(),
        note: note == null || note.isEmpty ? null : note,
        clearNote: note == null || note.isEmpty,
      ),
    );
  }
}
