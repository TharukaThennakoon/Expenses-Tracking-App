import 'dart:async';

import 'package:expenses_tracking_app/features/categories/data/datasources/category_data_source.dart';
import 'package:expenses_tracking_app/features/categories/data/models/category_model.dart';
import 'package:expenses_tracking_app/features/expenses/domain/entities/expense_category.dart';

/// Test stand-in for Firestore, seeded with [ExpenseCategory.defaults].
class InMemoryCategoryDataSource implements CategoryDataSource {
  InMemoryCategoryDataSource({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  final List<CategoryModel> _categories = ExpenseCategory.defaults
      .map(CategoryModel.fromEntity)
      .toList();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<CategoryModel>> getCategories() async => List.of(_categories);

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final saved = category.id.isNotEmpty
        ? category
        : category.copyWith(id: 'cat_${_clock().microsecondsSinceEpoch}');
    // Keep "Other" last so it reads as the catch-all.
    final otherIndex = _categories.indexWhere(
      (c) => c.id == ExpenseCategory.other.id,
    );
    _categories.insert(otherIndex < 0 ? _categories.length : otherIndex, saved);
    _changes.add(null);
    return saved;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _changes.add(null);
  }
}
