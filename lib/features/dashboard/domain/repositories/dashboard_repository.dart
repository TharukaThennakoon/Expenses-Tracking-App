import '../../../expenses/domain/entities/expense.dart';
import '../entities/monthly_summary.dart';
import '../entities/user_profile.dart';

abstract interface class DashboardRepository {
  Future<UserProfile> getUserProfile();

  /// Null removes the budget.
  Future<void> setMonthlyBudget(double? budget);

  /// Replaces the name and email; the budget is kept.
  Future<void> updateProfile(UserProfile profile);

  /// Emits whenever the profile (e.g. the budget) changes.
  Stream<void> watchProfileChanges();

  Future<MonthlySummary> getMonthlySummary(DateTime month);

  Future<List<Expense>> getRecentExpenses({int limit});
}
