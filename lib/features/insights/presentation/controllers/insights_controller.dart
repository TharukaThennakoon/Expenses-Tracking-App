import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../dashboard/domain/usecases/budget_usecases.dart';
import '../../../expenses/domain/usecases/watch_expense_changes.dart';
import '../../domain/entities/monthly_insights.dart';
import '../../domain/usecases/get_monthly_insights.dart';

enum InsightsStatus { loading, loaded, error }

class InsightsController extends ChangeNotifier {
  InsightsController({
    required this._getMonthlyInsights,
    required WatchExpenseChanges watchExpenseChanges,
    required WatchProfileChanges watchProfileChanges,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final now = _clock();
    _month = DateTime(now.year, now.month);
    _changesSub = watchExpenseChanges(const NoParams()).listen((_) => _fetch());
    _profileSub = watchProfileChanges(const NoParams()).listen((_) => _fetch());
  }

  /// How many months (including this one) the month picker offers.
  static const int monthsToShow = 12;

  final GetMonthlyInsights _getMonthlyInsights;
  final DateTime Function() _clock;
  late final StreamSubscription<void> _changesSub;
  late final StreamSubscription<void> _profileSub;

  InsightsStatus _status = InsightsStatus.loading;
  late DateTime _month;
  MonthlyInsights? _insights;
  Object? _error;
  int _requestId = 0;

  InsightsStatus get status => _status;
  DateTime get month => _month;
  MonthlyInsights? get insights => _insights;

  /// What made the last fetch fail; drives the error screen's wording.
  Object? get error => _error;

  List<DateTime> get availableMonths {
    final now = _clock();
    return [
      for (var i = 0; i < monthsToShow; i++) DateTime(now.year, now.month - i),
    ];
  }

  Future<void> load() async {
    _status = InsightsStatus.loading;
    notifyListeners();
    await _fetch();
  }

  void setMonth(DateTime month) {
    _month = DateTime(month.year, month.month);
    notifyListeners();
    _fetch();
  }

  Future<void> _fetch() async {
    final requestId = ++_requestId;
    try {
      final insights = await _getMonthlyInsights(_month);
      if (requestId != _requestId) return;
      _insights = insights;
      _error = null;
      _status = InsightsStatus.loaded;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e;
      _status = InsightsStatus.error;
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
