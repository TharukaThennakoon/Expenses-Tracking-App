import 'dart:async';
import 'dart:math' as math;

import 'package:expenses_tracking_app/features/expenses/data/datasources/expense_data_source.dart';
import 'package:expenses_tracking_app/features/expenses/data/models/expense_model.dart';

/// Test stand-in for Firestore, seeded with sample expenses.
class InMemoryExpenseDataSource implements ExpenseDataSource {
  InMemoryExpenseDataSource({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Keeps ids unique when several saves share a clock reading.
  var _nextId = 0;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  late final List<ExpenseModel> _expenses = _seed()
      .map(ExpenseModel.fromJson)
      .toList();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<ExpenseModel>> getExpenses() async => List.of(_expenses);

  @override
  Future<ExpenseModel> saveExpense(ExpenseModel expense) async {
    final now = _clock();
    final saved = expense.id.isNotEmpty
        ? expense.copyWith(createdAt: expense.createdAt ?? now)
        : expense.copyWith(
            id: 'exp_${now.microsecondsSinceEpoch}_${_nextId++}',
            createdAt: now,
          );
    _expenses
      ..removeWhere((e) => e.id == saved.id)
      ..add(saved);
    _changes.add(null);
    return saved;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    _changes.add(null);
  }

  @override
  Future<void> reassignCategory(String fromId, String toId) async {
    for (var i = 0; i < _expenses.length; i++) {
      if (_expenses[i].categoryId == fromId) {
        _expenses[i] = _expenses[i].copyWith(categoryId: toId);
      }
    }
    _changes.add(null);
  }

  List<Map<String, dynamic>> _seed() {
    final now = _clock();
    final prev = DateTime(now.year, now.month - 1);

    DateTime daysAgo(int days, int hour) =>
        DateTime(now.year, now.month, now.day - days, hour);
    // Older entries stay in the current month, before the recent ones.
    DateTime thisMonth(int day) => DateTime(
      now.year,
      now.month,
      math.max(1, math.min(day, now.day - 4)),
      9,
    );
    DateTime lastMonth(int day) => DateTime(prev.year, prev.month, day, 12);
    // Stays on today even just after midnight.
    DateTime earlierToday(Duration ago) {
      final time = now.subtract(ago);
      return time.day == now.day
          ? time
          : DateTime(now.year, now.month, now.day);
    }

    var id = 0;
    Map<String, dynamic> e(
      String title,
      num amount,
      String category,
      DateTime date, [
      String? note,
    ]) => {
      'id': 'exp_${id++}',
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': date.toIso8601String(),
    };

    return [
      // Current month.
      e(
        'Weekly groceries',
        6480,
        'food',
        earlierToday(const Duration(minutes: 40)),
        'Vegetables, rice, milk',
      ),
      e(
        'Ride to campus',
        1250,
        'transport',
        earlierToday(const Duration(hours: 3)),
      ),
      e('Internet bill', 4990, 'bills', daysAgo(1, 19), 'Fibre 100 Mbps'),
      e('Movie night', 1400, 'leisure', daysAgo(1, 16)),
      e('Pharmacy', 1850, 'health', daysAgo(3, 11)),
      e('New sneakers', 7800, 'shopping', thisMonth(22)),
      e('Dinner with friends', 7420, 'food', thisMonth(20), 'Pizza place'),
      e('Fuel refill', 9600, 'transport', thisMonth(18)),
      e('Concert tickets', 1900, 'leisure', thisMonth(16)),
      e('Electricity bill', 8710, 'bills', thisMonth(14), 'CEB'),
      e('Dental checkup', 3350, 'health', thisMonth(12)),
      e('Supermarket run', 8200, 'food', thisMonth(10)),
      e('Monthly train pass', 6000, 'transport', thisMonth(7)),
      e('Water bill', 4500, 'bills', thisMonth(5)),
      e('Books & stationery', 4500, 'shopping', thisMonth(4)),
      e('Groceries', 6300, 'food', thisMonth(2)),

      // Previous month.
      e('Groceries', 31200, 'food', lastMonth(25)),
      e('Utility bills', 19400, 'bills', lastMonth(20)),
      e('Transport', 18640, 'transport', lastMonth(15)),
      e('Clothing', 17500, 'shopping', lastMonth(10)),
      e('Doctor visit', 6000, 'health', lastMonth(8)),
      e('Miscellaneous', 3000, 'other', lastMonth(3)),
    ];
  }
}
