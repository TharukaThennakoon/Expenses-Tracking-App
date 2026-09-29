import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../repositories/category_repository.dart';

class GetCategories implements UseCase<List<ExpenseCategory>, NoParams> {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<List<ExpenseCategory>> call(NoParams params) =>
      _repository.getCategories();
}

class WatchCategoryChanges implements StreamUseCase<void, NoParams> {
  const WatchCategoryChanges(this._repository);

  final CategoryRepository _repository;

  @override
  Stream<void> call(NoParams params) => _repository.watchChanges();
}

/// Thrown by [AddCategory] when the input can't be saved.
class CategoryValidationException implements Exception {
  const CategoryValidationException(this.message);

  final String message;

  @override
  String toString() => 'CategoryValidationException($message)';
}

/// Adds a user-made category. The id is assigned by the data layer.
class AddCategory implements UseCase<ExpenseCategory, ExpenseCategory> {
  const AddCategory(this._repository);

  static const int maxLabelLength = 20;

  final CategoryRepository _repository;

  /// Why [label] can't be used, or null if it's fine.
  static String? validateLabel(
    String label,
    Iterable<ExpenseCategory> existing,
  ) {
    final name = label.trim();
    if (name.isEmpty) return 'Name is required';
    if (name.length > maxLabelLength) {
      return 'Keep it under $maxLabelLength characters';
    }
    final taken = existing.any(
      (c) => c.label.toLowerCase() == name.toLowerCase(),
    );
    return taken ? 'You already have "$name"' : null;
  }

  @override
  Future<ExpenseCategory> call(ExpenseCategory category) async {
    final error = validateLabel(
      category.label,
      await _repository.getCategories(),
    );
    if (error != null) throw CategoryValidationException(error);
    return _repository.addCategory(
      ExpenseCategory(
        id: '',
        label: category.label.trim(),
        iconKey: category.iconKey,
        colorKey: category.colorKey,
      ),
    );
  }
}

/// Deletes a category, moving its expenses to [ExpenseCategory.other] first
/// so nothing is lost.
class DeleteCategory implements UseCase<void, ExpenseCategory> {
  const DeleteCategory(this._categories, this._expenses);

  final CategoryRepository _categories;
  final ExpenseRepository _expenses;

  @override
  Future<void> call(ExpenseCategory category) async {
    if (!category.isDeletable) {
      throw ArgumentError('"${category.label}" cannot be deleted');
    }
    await _expenses.reassignCategory(category.id, ExpenseCategory.other.id);
    await _categories.deleteCategory(category.id);
  }
}
