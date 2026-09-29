import '../../../expenses/domain/entities/expense_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._dataSource);

  final CategoryDataSource _dataSource;

  @override
  Future<List<ExpenseCategory>> getCategories() async =>
      (await _dataSource.getCategories()).map((m) => m.toEntity()).toList();

  @override
  Future<ExpenseCategory> addCategory(ExpenseCategory category) async =>
      (await _dataSource.addCategory(
        CategoryModel.fromEntity(category),
      )).toEntity();

  @override
  Future<void> deleteCategory(String id) => _dataSource.deleteCategory(id);

  @override
  Stream<void> watchChanges() => _dataSource.changes;
}
