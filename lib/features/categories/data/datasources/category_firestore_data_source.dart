import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/user_data.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../models/category_model.dart';
import 'category_data_source.dart';

/// Categories in Firestore at `users/{uid}/categories/{id}`. A new account
/// starts with [ExpenseCategory.defaults].
class CategoryFirestoreDataSource implements CategoryDataSource {
  CategoryFirestoreDataSource(this._user);

  final UserData _user;

  CollectionReference<Map<String, dynamic>> _categories(
    DocumentReference<Map<String, dynamic>> user,
  ) => user.collection('categories');

  @override
  Stream<void> get changes =>
      _user.changes((user) => _categories(user).snapshots());

  @override
  Future<List<CategoryModel>> getCategories() async {
    final collection = _categories(_user.doc);
    final snapshot = await collection.orderBy('order').get();
    if (snapshot.docs.isEmpty) return _addDefaults(collection);
    final categories = snapshot.docs.map(_fromDoc).toList();
    // Keep "Other" last so it reads as the catch-all.
    final other = categories.indexWhere(
      (c) => c.id == ExpenseCategory.other.id,
    );
    if (other >= 0) categories.add(categories.removeAt(other));
    return categories;
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final collection = _categories(_user.doc);
    final doc = category.id.isEmpty
        ? collection.doc()
        : collection.doc(category.id);
    final saved = category.copyWith(id: doc.id);
    // Newest last, after the defaults.
    await doc.set(_toData(saved, DateTime.now().millisecondsSinceEpoch));
    return saved;
  }

  @override
  Future<void> deleteCategory(String id) =>
      _categories(_user.doc).doc(id).delete();

  /// Writes the defaults for a new account. Safe to run twice: same ids.
  Future<List<CategoryModel>> _addDefaults(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final defaults = ExpenseCategory.defaults
        .map(CategoryModel.fromEntity)
        .toList();
    final batch = _user.firestore.batch();
    for (final (i, category) in defaults.indexed) {
      batch.set(collection.doc(category.id), _toData(category, i));
    }
    await batch.commit();
    return defaults;
  }

  static CategoryModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      label: data['label'] as String,
      iconKey: data['icon'] as String,
      colorKey: data['color'] as String,
    );
  }

  static Map<String, dynamic> _toData(CategoryModel category, int order) => {
    'label': category.label,
    'icon': category.iconKey,
    'color': category.colorKey,
    'order': order,
  };
}
