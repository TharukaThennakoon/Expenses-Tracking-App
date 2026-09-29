import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/user_data.dart';
import '../models/user_profile_model.dart';
import 'dashboard_data_source.dart';

/// The profile in Firestore, on the user's own document `users/{uid}`.
class DashboardFirestoreDataSource implements DashboardDataSource {
  DashboardFirestoreDataSource(this._user);

  final UserData _user;

  @override
  Stream<void> get changes => _user.changes((user) => user.snapshots());

  /// Empty fields (and no budget) until the profile is first saved.
  @override
  Future<UserProfileModel> getUserProfile() async {
    final data = (await _user.doc.get()).data() ?? const {};
    return UserProfileModel(
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> setMonthlyBudget(double? budget) =>
      _user.doc.set({'monthlyBudget': budget}, _merge);

  @override
  Future<void> updateName({
    required String firstName,
    required String lastName,
    required String email,
  }) => _user.doc.set({
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  }, _merge);

  static final _merge = SetOptions(merge: true);
}
