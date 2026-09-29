import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/budget_sheet.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_group.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  Future<void> _pickCurrency() async {
    final picked = await showCurrencyPicker(
      context,
      selected: _controller.currency,
    );
    if (picked != null) _controller.setCurrency(picked);
  }

  Future<void> _editProfile() async {
    final profile = _controller.profile;
    if (profile == null) return;
    final saved = await showEditProfileSheet(
      context,
      profile: profile,
      onSave: _controller.updateProfile,
    );
    if (saved != true || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _controller.signOut();
    if (mounted) AppRoutes.backToAuthWrapper(context);
  }

  // Adds sample data; used by the commented-out tile below.
  // Future<void> _addSampleData() async {
  //   final messenger = ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(const SnackBar(content: Text('Adding sample data…')));
  //   String message;
  //   try {
  //     final count = await _controller.addSampleData();
  //     message = 'Added $count sample expenses';
  //   } catch (_) {
  //     message = 'Couldn’t add sample data. Check your connection.';
  //   }
  //   messenger
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(SnackBar(content: Text(message)));
  // }

  Future<void> _editBudget() async {
    final change = await showBudgetSheet(
      context,
      current: _controller.profile?.monthlyBudget,
    );
    if (change == null) return;
    await _controller.setMonthlyBudget(change.budget);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            change.budget == null ? 'Budget removed' : 'Budget saved',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.status == SettingsStatus.error) {
          return ErrorStateView(
            title: 'Couldn’t load your settings',
            error: _controller.error,
            onRetry: _controller.load,
          );
        }
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final profile = _controller.profile;
    if (profile == null) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primaryText),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        ProfileCard(profile: profile, onTap: _editProfile),
        const SizedBox(height: 24),
        SettingsGroup(
          title: 'Preferences',
          tiles: [
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              iconColor: AppColors.accent,
              iconBackground: AppColors.ink,
              label: 'Dark mode',
              onTap: () => _controller.setDarkMode(!_controller.darkMode),
              trailing: Switch(
                value: _controller.darkMode,
                onChanged: _controller.setDarkMode,
                activeThumbColor: AppColors.accent,
                activeTrackColor: context.colors.primary,
                inactiveThumbColor: context.colors.surface,
                inactiveTrackColor: context.colors.border,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ),
            SettingsTile(
              icon: Icons.language_rounded,
              iconColor: context.colors.primaryText,
              iconBackground: context.colors.tintGreen,
              label: 'Currency',
              value: _controller.currency.code,
              onTap: _pickCurrency,
            ),
            SettingsTile(
              icon: Icons.track_changes_rounded,
              iconColor: context.colors.olive,
              iconBackground: context.colors.tintLime,
              label: 'Monthly budget',
              value: switch (profile.monthlyBudget) {
                null => 'Not set',
                final budget => Formatters.wholeAmount(budget),
              },
              onTap: _editBudget,
            ),
            SettingsTile(
              icon: Icons.sell_outlined,
              iconColor: context.colors.purple,
              iconBackground: context.colors.tintPurple,
              label: 'Categories',
              value: '${context.categories.length}',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.categories),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          title: 'Data & account',
          tiles: [
            SettingsTile(
              icon: Icons.download_rounded,
              iconColor: context.colors.blue,
              iconBackground: context.colors.tintBlue,
              label: 'Export to CSV',
              onTap: () => _comingSoon('CSV export'),
            ),
            // Sample data button, hidden for now. Uncomment to use it again.
            // if (_controller.canAddSampleData)
            //   SettingsTile(
            //     icon: Icons.science_outlined,
            //     iconColor: context.colors.olive,
            //     iconBackground: context.colors.tintLime,
            //     label: 'Add sample data',
            //     value: 'Debug',
            //     onTap: _addSampleData,
            //   ),
            SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: context.colors.danger,
              iconBackground: context.colors.dangerSurface,
              label: 'Sign out',
              showChevron: false,
              destructive: true,
              onTap: _signOut,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '${AppConstants.appName} ${AppConstants.appVersion} · '
          'Built with Flutter',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
