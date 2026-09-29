import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    categoryId: json['category'] as String,
    date: DateTime.parse(json['date'] as String),
    note: json['note'] as String?,
    createdAt: switch (json['createdAt']) {
      final String value => DateTime.parse(value),
      _ => null,
    },
  );

  factory ExpenseModel.fromEntity(Expense expense) => ExpenseModel(
    id: expense.id,
    title: expense.title,
    amount: expense.amount,
    categoryId: expense.category.id,
    date: expense.date,
    note: expense.note,
    createdAt: expense.createdAt,
  );

  final String id;
  final String title;
  final double amount;

  /// Id of an [ExpenseCategory]; resolved by the repository.
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime? createdAt;

  ExpenseModel copyWith({
    String? id,
    String? categoryId,
    DateTime? createdAt,
  }) => ExpenseModel(
    id: id ?? this.id,
    title: title,
    amount: amount,
    categoryId: categoryId ?? this.categoryId,
    date: date,
    note: note,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': categoryId,
    'date': date.toIso8601String(),
    'note': note,
    'createdAt': createdAt?.toIso8601String(),
  };

  Expense toEntity(ExpenseCategory category) => Expense(
    id: id,
    title: title,
    amount: amount,
    category: category,
    date: date,
    note: note,
    createdAt: createdAt,
  );
}
