import '../models/user_profile_model.dart';

abstract interface class DashboardDataSource {
  Future<UserProfileModel> getUserProfile();

  /// Null removes the budget.
  Future<void> setMonthlyBudget(double? budget);

  Future<void> updateName({
    required String firstName,
    required String lastName,
    required String email,
  });

  /// Emits whenever the profile (e.g. the budget) changes.
  Stream<void> get changes;
}
