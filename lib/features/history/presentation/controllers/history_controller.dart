import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/domain/usecases/delete_expense.dart';
import '../../../expenses/domain/usecases/watch_expense_changes.dart';
import '../../domain/entities/expense_history.dart';
import '../../domain/entities/history_filter.dart';
import '../../domain/usecases/get_expense_history.dart';

enum HistoryStatus { loading, loaded, error }

class HistoryController extends ChangeNotifier {
  HistoryController({
    required this._getExpenseHistory,
    required this._deleteExpense,
    required WatchExpenseChanges watchExpenseChanges,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final now = _clock();
    _filter = HistoryFilter.initial(now);
    _changesSub = watchExpenseChanges(const NoParams()).listen((_) => _fetch());
  }

  final GetExpenseHistory _getExpenseHistory;
  final DeleteExpense _deleteExpense;
  final DateTime Function() _clock;
  late final StreamSubscription<void> _changesSub;

  HistoryStatus _status = HistoryStatus.loading;
  late HistoryFilter _filter;
  ExpenseHistory _history = const ExpenseHistory(groups: []);
  Object? _error;
  int _requestId = 0;

  HistoryStatus get status => _status;

  /// What made the last fetch fail; drives the error screen's wording.
  Object? get error => _error;
  HistoryFilter get filter => _filter;
  ExpenseHistory get history => _history;
  DateTime get now => _clock();

  /// Nothing logged this month and no search or filters applied, so the
  /// user should see the "add your first expense" state.
  bool get isEmptyMonth =>
      _status == HistoryStatus.loaded &&
      _history.isEmpty &&
      _filter.query.isEmpty &&
      _filter.activeCount == 0;

  Future<void> load() async {
    _status = HistoryStatus.loading;
    notifyListeners();
    await _fetch();
  }

  void setQuery(String query) {
    if (query == _filter.query) return;
    _updateFilter(_filter.copyWith(query: query));
  }

  /// Replaces category, date and sort settings; keeps the search query.
  void applyFilter(HistoryFilter filter) =>
      _updateFilter(filter.copyWith(query: _filter.query));

  /// How many expenses [filter] would show (used for a live preview).
  Future<int> countMatching(HistoryFilter filter) async =>
      (await _getExpenseHistory(filter.copyWith(query: _filter.query))).count;

  void setCategories(Set<ExpenseCategory> categories) =>
      _updateFilter(_filter.copyWith(categories: Set.unmodifiable(categories)));

  void removeCategory(ExpenseCategory category) =>
      setCategories({..._filter.categories}..remove(category));

  void clearCategories() => setCategories(const {});

  Future<void> deleteExpense(Expense expense) => _deleteExpense(expense.id);

  void _updateFilter(HistoryFilter filter) {
    _filter = filter;
    notifyListeners();
    _fetch();
  }

  Future<void> _fetch() async {
    // Ignore responses from requests that were superseded by newer ones.
    final requestId = ++_requestId;
    try {
      final history = await _getExpenseHistory(_filter);
      if (requestId != _requestId) return;
      _history = history;
      _error = null;
      _status = HistoryStatus.loaded;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e;
      _status = HistoryStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _changesSub.cancel();
    super.dispose();
  }
}
