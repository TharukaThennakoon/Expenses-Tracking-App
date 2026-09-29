import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../insights/presentation/controllers/insights_controller.dart';
import '../../../insights/presentation/pages/insights_page.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Hosts the bottom navigation and the top-level tabs.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const _homeTab = 0;
  static const _historyTab = 1;
  static const _insightsTab = 2;

  static const _navItems = [
    NavItem(label: 'Home', icon: Icons.home_outlined),
    NavItem(label: 'History', icon: Icons.format_list_bulleted_rounded),
    NavItem(label: 'Insights', icon: Icons.bar_chart_rounded),
    NavItem(label: 'Settings', icon: Icons.tune_rounded),
  ];

  late final DashboardController _dashboardController = InjectionContainer
      .instance
      .dashboardController();

  late final HistoryController _historyController = InjectionContainer.instance
      .historyController();

  late final InsightsController _insightsController = InjectionContainer
      .instance
      .insightsController();

  late final SettingsController _settingsController = InjectionContainer
      .instance
      .settingsController();

  int _currentIndex = _homeTab;

  @override
  void dispose() {
    _dashboardController.dispose();
    _historyController.dispose();
    _insightsController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  void _selectTab(int index) => setState(() => _currentIndex = index);

  Future<void> _onAddExpense() async {
    final result = await AppRoutes.openExpenseForm(context);
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            controller: _dashboardController,
            onOpenHistory: () => _selectTab(_historyTab),
            onOpenInsights: () => _selectTab(_insightsTab),
          ),
          HistoryPage(controller: _historyController),
          InsightsPage(controller: _insightsController),
          SettingsPage(controller: _settingsController),
        ],
      ),
      // Hidden while the keyboard is up so it doesn't float over content.
      floatingActionButton: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : AddExpenseButton(onPressed: _onAddExpense),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _selectTab,
      ),
    );
  }
}
