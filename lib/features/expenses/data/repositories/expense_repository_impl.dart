import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._dataSource, this._categories);

  final ExpenseDataSource _dataSource;

  /// Used to turn stored category ids back into categories.
  final CategoryRepository _categories;

  @override
  Future<List<Expense>> getExpenses() async {
    final byId = {for (final c in await _categories.getCategories()) c.id: c};
    final models = await _dataSource.getExpenses()
      ..sort((a, b) => b.date.compareTo(a.date));
    return models
        .map((m) => m.toEntity(byId[m.categoryId] ?? ExpenseCategory.other))
        .toList();
  }

  @override
  Future<Expense> saveExpense(Expense expense) async =>
      (await _dataSource.saveExpense(
        ExpenseModel.fromEntity(expense),
      )).toEntity(expense.category);

  @override
  Future<void> deleteExpense(String id) => _dataSource.deleteExpense(id);

  @override
  Future<void> reassignCategory(String fromId, String toId) =>
      _dataSource.reassignCategory(fromId, toId);

  @override
  Stream<void> watchChanges() => _dataSource.changes;
}
