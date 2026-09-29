import '../models/category_model.dart';

abstract interface class CategoryDataSource {
  /// All categories in display order.
  Future<List<CategoryModel>> getCategories();

  /// Stores a new category. An empty id gets a new one. Returns it.
  Future<CategoryModel> addCategory(CategoryModel category);

  Future<void> deleteCategory(String id);

  Stream<void> get changes;
}
