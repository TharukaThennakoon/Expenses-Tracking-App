import 'expense_category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.createdAt,
  });

  /// Empty for an expense that hasn't been saved yet.
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;

  /// When the money was spent.
  final DateTime date;
  final String? note;

  /// When the expense was first recorded; set by the data layer.
  final DateTime? createdAt;

  bool get isNew => id.isEmpty;

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    bool clearNote = false,
  }) => Expense(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    date: date ?? this.date,
    note: clearNote ? null : note ?? this.note,
    createdAt: createdAt,
  );
}
