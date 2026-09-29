import 'dart:async';

import 'package:expenses_tracking_app/features/dashboard/data/datasources/dashboard_data_source.dart';
import 'package:expenses_tracking_app/features/dashboard/data/models/user_profile_model.dart';

/// Test stand-in for Firestore, with a sample profile.
class InMemoryDashboardDataSource implements DashboardDataSource {
  InMemoryDashboardDataSource();

  final StreamController<void> _changes = StreamController<void>.broadcast();

  UserProfileModel _profile = UserProfileModel.fromJson(const {
    'firstName': 'John',
    'lastName': 'Nethmina',
    'email': 'john@example.com',
    'monthlyBudget': 125000,
  });

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<UserProfileModel> getUserProfile() async => _profile;

  @override
  Future<void> setMonthlyBudget(double? budget) async {
    _profile = _profile.withBudget(budget);
    _changes.add(null);
  }

  @override
  Future<void> updateName({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    _changes.add(null);
  }
}
