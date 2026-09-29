import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/currency/currency.dart';
import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../dashboard/domain/entities/user_profile.dart';
import '../../../dashboard/domain/usecases/budget_usecases.dart';
import '../../../dashboard/domain/usecases/get_user_profile.dart';
import '../../../dashboard/domain/usecases/update_profile.dart';
import '../../../expenses/domain/usecases/add_sample_data.dart';

enum SettingsStatus { loading, loaded, error }

class SettingsController extends ChangeNotifier {
  SettingsController({
    required this._getUserProfile,
    required this._setMonthlyBudget,
    required this._updateProfile,
    required this._signOut,
    required WatchProfileChanges watchProfileChanges,
    required this._themeController,
    required this._currencyController,
    this._addSampleData,
  }) {
    _profileSub = watchProfileChanges(
      const NoParams(),
    ).listen((_) => _reloadProfile());
    _themeController.addListener(notifyListeners);
    _currencyController.addListener(notifyListeners);
  }

  final GetUserProfile _getUserProfile;
  final SetMonthlyBudget _setMonthlyBudget;
  final UpdateProfile _updateProfile;
  final SignOut _signOut;
  late final StreamSubscription<void> _profileSub;
  final ThemeController _themeController;
  final CurrencyController _currencyController;

  /// Null outside debug builds.
  final AddSampleData? _addSampleData;

  SettingsStatus _status = SettingsStatus.loading;
  UserProfile? _profile;
  Object? _error;

  SettingsStatus get status => _status;
  UserProfile? get profile => _profile;
  bool get darkMode => _themeController.isDark;
  Currency get currency => _currencyController.currency;

  /// What made [load] fail; drives the error screen's wording.
  Object? get error => _error;

  Future<void> load() async {
    _status = SettingsStatus.loading;
    notifyListeners();
    try {
      _profile = await _getUserProfile(const NoParams());
      _error = null;
      _status = SettingsStatus.loaded;
    } catch (e) {
      _error = e;
      _status = SettingsStatus.error;
    }
    notifyListeners();
  }

  /// Reloads the profile in place (no spinner) after it changes.
  Future<void> _reloadProfile() async {
    if (_status != SettingsStatus.loaded) return;
    try {
      _profile = await _getUserProfile(const NoParams());
      notifyListeners();
    } catch (_) {
      // Keep showing the last good profile.
    }
  }

  /// Throws [ProfileValidationException] if the input is invalid.
  Future<void> updateProfile(UserProfile profile) => _updateProfile(profile);

  Future<void> signOut() => _signOut(const NoParams());

  bool get canAddSampleData => _addSampleData != null;

  /// Returns how many expenses were added.
  Future<int> addSampleData() => _addSampleData!(const NoParams());

  /// Null removes the budget.
  Future<void> setMonthlyBudget(double? budget) => _setMonthlyBudget(budget);

  void setDarkMode(bool value) => _themeController.setDark(value);

  void setCurrency(Currency currency) =>
      _currencyController.setCurrency(currency);

  @override
  void dispose() {
    _profileSub.cancel();
    _themeController.removeListener(notifyListeners);
    _currencyController.removeListener(notifyListeners);
    super.dispose();
  }
}
