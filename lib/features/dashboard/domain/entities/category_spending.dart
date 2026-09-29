import '../../../expenses/domain/entities/expense_category.dart';

class CategorySpending {
  const CategorySpending({required this.category, required this.amount});

  final ExpenseCategory category;
  final double amount;
}
