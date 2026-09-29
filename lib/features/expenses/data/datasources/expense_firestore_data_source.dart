import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/user_data.dart';
import '../models/expense_model.dart';
import 'expense_data_source.dart';

/// Expenses in Firestore at `users/{uid}/expenses/{id}`.
class ExpenseFirestoreDataSource implements ExpenseDataSource {
  ExpenseFirestoreDataSource(this._user);

  final UserData _user;

  CollectionReference<Map<String, dynamic>> _expenses(
    DocumentReference<Map<String, dynamic>> user,
  ) => user.collection('expenses');

  @override
  Stream<void> get changes =>
      _user.changes((user) => _expenses(user).snapshots());

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final snapshot = await _expenses(_user.doc).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<ExpenseModel> saveExpense(ExpenseModel expense) async {
    final collection = _expenses(_user.doc);
    final doc = expense.id.isEmpty
        ? collection.doc()
        : collection.doc(expense.id);
    final saved = expense.copyWith(
      id: doc.id,
      createdAt: expense.createdAt ?? DateTime.now(),
    );
    await doc.set(_toData(saved));
    return saved;
  }

  @override
  Future<void> deleteExpense(String id) =>
      _expenses(_user.doc).doc(id).delete();

  @override
  Future<void> reassignCategory(String fromId, String toId) async {
    final collection = _expenses(_user.doc);
    final affected = await collection
        .where('category', isEqualTo: fromId)
        .get();
    // A batch holds up to 500 writes.
    for (var i = 0; i < affected.docs.length; i += 500) {
      final batch = _user.firestore.batch();
      for (final doc in affected.docs.skip(i).take(500)) {
        batch.update(doc.reference, {'category': toId});
      }
      await batch.commit();
    }
  }

  static ExpenseModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ExpenseModel(
      id: doc.id,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['category'] as String,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> _toData(ExpenseModel expense) => {
    'title': expense.title,
    'amount': expense.amount,
    'category': expense.categoryId,
    'date': Timestamp.fromDate(expense.date),
    'note': expense.note,
    'createdAt': switch (expense.createdAt) {
      final createdAt? => Timestamp.fromDate(createdAt),
      null => null,
    },
  };
}
