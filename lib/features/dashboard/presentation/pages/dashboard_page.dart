import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/month_picker_sheet.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/recent_expenses_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.controller,
    this.onOpenInsights,
    this.onOpenHistory,
  });

  final DashboardController controller;
  final VoidCallback? onOpenInsights;
  final VoidCallback? onOpenHistory;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  /// Opens the expense for editing or deleting.
  Future<void> _openExpense(Expense expense) async {
    final result = await AppRoutes.openExpenseForm(context, expense: expense);
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPickerSheet(
      context,
      selected: _controller.selectedMonth,
      months: _controller.availableMonths,
    );
    if (picked != null) await _controller.selectMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return switch (_controller.status) {
          DashboardStatus.loading => const DashboardSkeleton(),
          DashboardStatus.error => ErrorStateView(
            title: 'Couldn’t load your expenses',
            error: _controller.error,
            onRetry: _controller.load,
          ),
          DashboardStatus.loaded => _buildContent(),
        };
      },
    );
  }

  Widget _buildContent() {
    final summary = _controller.summary!;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: context.colors.primaryText,
        onRefresh: _controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            DashboardHeader(profile: _controller.profile!),
            const SizedBox(height: 20),
            MonthlySummaryCard(
              summary: summary,
              onPrevious: _controller.previousMonth,
              onNext: _controller.canGoToNextMonth
                  ? _controller.nextMonth
                  : null,
              onPickMonth: _pickMonth,
              isCurrentMonth: _controller.isCurrentMonth,
            ),
            const SizedBox(height: 16),
            CategoryBreakdownCard(
              categories: summary.categories,
              onInsightsTap: widget.onOpenInsights,
            ),
            const SizedBox(height: 24),
            RecentExpensesSection(
              expenses: _controller.recentExpenses,
              onSeeAll: widget.onOpenHistory,
              onExpenseTap: _openExpense,
            ),
          ],
        ),
      ),
    );
  }
}
