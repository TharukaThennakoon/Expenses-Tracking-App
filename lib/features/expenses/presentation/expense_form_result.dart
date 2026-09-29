import '../domain/entities/expense.dart';

/// What happened on the expense form. The route pops with this, or null
/// if the user left without changes.
sealed class ExpenseFormResult {
  const ExpenseFormResult(this.expense);

  final Expense expense;

  /// Short confirmation to show in a snackbar.
  String get message;
}

final class ExpenseSaved extends ExpenseFormResult {
  const ExpenseSaved(super.expense, {required this.isNew});

  final bool isNew;

  @override
  String get message => isNew ? '"${expense.title}" added' : 'Changes saved';
}

final class ExpenseDeleted extends ExpenseFormResult {
  const ExpenseDeleted(super.expense);

  @override
  String get message => '"${expense.title}" deleted';
}
