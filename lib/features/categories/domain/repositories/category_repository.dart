import '../../../expenses/domain/entities/expense_category.dart';

abstract interface class CategoryRepository {
  /// All categories in display order ("Other" last).
  Future<List<ExpenseCategory>> getCategories();

  /// Stores a new category and returns it with its id.
  Future<ExpenseCategory> addCategory(ExpenseCategory category);

  Future<void> deleteCategory(String id);

  /// Emits whenever categories are added or removed.
  Stream<void> watchChanges();
}
