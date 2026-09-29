import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../domain/usecases/category_usecases.dart';

/// App-wide list of categories. Screens read it through [CategoriesScope].
class CategoriesController extends ChangeNotifier {
  CategoriesController({
    required this._getCategories,
    required this._addCategory,
    required this._deleteCategory,
    required WatchCategoryChanges watchCategoryChanges,
  }) {
    _changesSub = watchCategoryChanges(const NoParams()).listen((_) => load());
    load();
  }

  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final DeleteCategory _deleteCategory;
  late final StreamSubscription<void> _changesSub;

  // Start with the defaults so the first frame already has something.
  List<ExpenseCategory> _categories = ExpenseCategory.defaults;

  List<ExpenseCategory> get categories => _categories;

  Future<void> load() async {
    try {
      _categories = await _getCategories(const NoParams());
      notifyListeners();
    } catch (_) {
      // Keep showing the last good list.
    }
  }

  /// Why [label] can't be used, or null if it's fine.
  String? validateLabel(String label) =>
      AddCategory.validateLabel(label, _categories);

  /// Throws [CategoryValidationException] if the input is invalid.
  Future<ExpenseCategory> add(ExpenseCategory category) =>
      _addCategory(category);

  Future<void> delete(ExpenseCategory category) => _deleteCategory(category);

  @override
  void dispose() {
    _changesSub.cancel();
    super.dispose();
  }
}

/// Provides the [CategoriesController] below it, rebuilding dependents
/// when the list changes.
class CategoriesScope extends InheritedNotifier<CategoriesController> {
  const CategoriesScope({
    super.key,
    required CategoriesController controller,
    required super.child,
  }) : super(notifier: controller);

  static CategoriesController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CategoriesScope>()?.notifier;
}

extension CategoriesContext on BuildContext {
  /// Current categories, or the defaults outside a [CategoriesScope].
  List<ExpenseCategory> get categories =>
      CategoriesScope.maybeOf(this)?.categories ?? ExpenseCategory.defaults;
}
