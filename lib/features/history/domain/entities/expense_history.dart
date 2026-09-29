import '../../../expenses/domain/entities/expense.dart';

/// A block of expenses shown together.
///
/// When sorted by date, each group is one calendar day ([date] is set).
/// When sorted by amount there is a single group with a null [date].
class ExpenseGroup {
  const ExpenseGroup({required this.expenses, this.date});

  final DateTime? date;
  final List<Expense> expenses;

  double get total => expenses.fold(0, (sum, e) => sum + e.amount);
}

class ExpenseHistory {
  const ExpenseHistory({required this.groups});

  final List<ExpenseGroup> groups;

  int get count => groups.fold(0, (sum, g) => sum + g.expenses.length);

  double get total => groups.fold(0, (sum, g) => sum + g.total);

  bool get isEmpty => groups.isEmpty;
}
