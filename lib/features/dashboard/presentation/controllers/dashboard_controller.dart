import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/usecases/watch_expense_changes.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/budget_usecases.dart';
import '../../domain/usecases/get_monthly_summary.dart';
import '../../domain/usecases/get_recent_expenses.dart';
import '../../domain/usecases/get_user_profile.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this._getUserProfile,
    required this._getMonthlySummary,
    required this._getRecentExpenses,
    required WatchExpenseChanges watchExpenseChanges,
    required WatchProfileChanges watchProfileChanges,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final now = _clock();
    _selectedMonth = DateTime(now.year, now.month);
    _changesSub = watchExpenseChanges(
      const NoParams(),
    ).listen((_) => _refresh());
    _profileSub = watchProfileChanges(
      const NoParams(),
    ).listen((_) => _refresh());
  }

  static const int recentLimit = 3;

  /// How many months (including this one) the month picker offers.
  static const int monthsToShow = 12;

  final GetUserProfile _getUserProfile;
  final GetMonthlySummary _getMonthlySummary;
  final GetRecentExpenses _getRecentExpenses;
  final DateTime Function() _clock;
  late final StreamSubscription<void> _changesSub;
  late final StreamSubscription<void> _profileSub;

  DashboardStatus _status = DashboardStatus.loading;
  late DateTime _selectedMonth;
  UserProfile? _profile;
  MonthlySummary? _summary;
  List<Expense> _recentExpenses = const [];
  String? _errorMessage;
  int _monthRequestId = 0;
  Object? _error;

  DashboardStatus get status => _status;
  DateTime get selectedMonth => _selectedMonth;
  UserProfile? get profile => _profile;
  MonthlySummary? get summary => _summary;
  List<Expense> get recentExpenses => _recentExpenses;
  String? get errorMessage => _errorMessage;

  /// What made [load] fail; drives the error screen's wording.
  Object? get error => _error;

  bool get isCurrentMonth {
    final now = _clock();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  /// Months the picker offers, newest first.
  List<DateTime> get availableMonths {
    final now = _clock();
    return [
      for (var i = 0; i < monthsToShow; i++) DateTime(now.year, now.month - i),
    ];
  }

  bool get canGoToNextMonth {
    final now = _clock();
    return _selectedMonth.isBefore(DateTime(now.year, now.month));
  }

  Future<void> load() async {
    _status = DashboardStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _getUserProfile(const NoParams()),
        _getMonthlySummary(_selectedMonth),
        _getRecentExpenses(recentLimit),
      ]);
      _profile = results[0] as UserProfile;
      _summary = results[1] as MonthlySummary;
      _recentExpenses = results[2] as List<Expense>;
      _error = null;
      _status = DashboardStatus.loaded;
    } catch (e) {
      _error = e;
      _errorMessage = 'Could not load your dashboard.';
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }

  /// Reloads data in place (no loading spinner) after expenses or the
  /// profile change.
  Future<void> _refresh() async {
    if (_status != DashboardStatus.loaded) return;
    try {
      _profile = await _getUserProfile(const NoParams());
      _summary = await _getMonthlySummary(_selectedMonth);
      _recentExpenses = await _getRecentExpenses(recentLimit);
      notifyListeners();
    } catch (_) {
      // Keep showing the last good data.
    }
  }

  Future<void> previousMonth() => _changeMonth(-1);

  Future<void> nextMonth() async {
    if (canGoToNextMonth) await _changeMonth(1);
  }

  Future<void> _changeMonth(int delta) =>
      selectMonth(DateTime(_selectedMonth.year, _selectedMonth.month + delta));

  /// Shows [month]'s summary. Future months are ignored.
  Future<void> selectMonth(DateTime month) async {
    final target = DateTime(month.year, month.month);
    final now = _clock();
    if (target.isAfter(DateTime(now.year, now.month))) return;
    if (target == _selectedMonth) return;

    _selectedMonth = target;
    notifyListeners();
    // Ignore responses from months the user has already moved past.
    final requestId = ++_monthRequestId;
    try {
      final summary = await _getMonthlySummary(target);
      if (requestId != _monthRequestId) return;
      _summary = summary;
    } catch (_) {
      if (requestId != _monthRequestId) return;
      _errorMessage = 'Could not load this month.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _changesSub.cancel();
    _profileSub.cancel();
    super.dispose();
  }
}
