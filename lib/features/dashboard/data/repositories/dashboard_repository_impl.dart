import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../domain/entities/category_spending.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(
    this._dataSource,
    this._expenseRepository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DashboardDataSource _dataSource;
  final ExpenseRepository _expenseRepository;
  final DateTime Function() _clock;

  @override
  Future<UserProfile> getUserProfile() async =>
      (await _dataSource.getUserProfile()).toEntity();

  @override
  Future<void> setMonthlyBudget(double? budget) =>
      _dataSource.setMonthlyBudget(budget);

  @override
  Future<void> updateProfile(UserProfile profile) => _dataSource.updateName(
    firstName: profile.firstName,
    lastName: profile.lastName,
    email: profile.email,
  );

  @override
  Stream<void> watchProfileChanges() => _dataSource.changes;

  @override
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final profile = await _dataSource.getUserProfile();
    final expenses = await _expenseRepository.getExpenses();

    final current = _inMonth(expenses, month);
    final previous = _inMonth(expenses, DateTime(month.year, month.month - 1));

    final totals = <ExpenseCategory, double>{};
    for (final e in current) {
      totals.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    final categories =
        totals.entries
            .map((t) => CategorySpending(category: t.key, amount: t.value))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return MonthlySummary(
      month: month,
      totalSpent: _sum(current),
      budget: profile.monthlyBudget,
      previousMonthSpent: _sum(previous),
      daysCounted: _daysCounted(month),
      categories: categories,
    );
  }

  @override
  Future<List<Expense>> getRecentExpenses({int limit = 3}) async =>
      (await _expenseRepository.getExpenses()).take(limit).toList();

  List<Expense> _inMonth(List<Expense> expenses, DateTime month) => expenses
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  double _sum(List<Expense> expenses) =>
      expenses.fold(0, (total, e) => total + e.amount);

  int _daysCounted(DateTime month) {
    final now = _clock();
    if (month.year == now.year && month.month == now.month) return now.day;
    if (month.isAfter(now)) return 0;
    return DateTime(month.year, month.month + 1, 0).day;
  }
}
