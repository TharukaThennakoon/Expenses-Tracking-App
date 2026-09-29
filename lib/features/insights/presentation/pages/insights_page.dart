import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../controllers/insights_controller.dart';
import '../widgets/category_donut_card.dart';
import '../widgets/insight_stat_cards.dart';
import '../widgets/month_picker_button.dart';
import '../widgets/weekly_spending_card.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.controller});

  final InsightsController controller;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  InsightsController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.status == InsightsStatus.error) {
          return ErrorStateView(
            title: 'Couldn’t load your insights',
            error: _controller.error,
            onRetry: _controller.load,
          );
        }
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    MonthPickerButton(
                      month: _controller.month,
                      months: _controller.availableMonths,
                      onChanged: _controller.setMonth,
                    ),
                  ],
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
    final insights = _controller.insights;
    if (insights == null) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primaryText),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        InsightStatCards(insights: insights),
        const SizedBox(height: 16),
        CategoryDonutCard(
          shares: insights.categories,
          expenseCount: insights.expenseCount,
        ),
        const SizedBox(height: 16),
        WeeklySpendingCard(weeks: insights.weeks),
      ],
    );
  }
}
