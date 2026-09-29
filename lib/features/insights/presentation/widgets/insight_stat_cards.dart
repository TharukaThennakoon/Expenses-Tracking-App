import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/monthly_insights.dart';

/// "Total spent" (dark) and "Budget left" (light) side by side.
class InsightStatCards extends StatelessWidget {
  const InsightStatCards({super.key, required this.insights});

  final MonthlyInsights insights;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _TotalSpentCard(insights: insights)),
          const SizedBox(width: 12),
          Expanded(child: _BudgetLeftCard(insights: insights)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.footer,
    required this.dark,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? footer;
  final bool dark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: dark ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: dark ? null : Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: dark
                  ? AppColors.textOnPrimaryMuted
                  : context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color:
                    valueColor ??
                    (dark
                        ? AppColors.textOnPrimary
                        : context.colors.textPrimary),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
        ],
      ),
    );
  }
}

class _TotalSpentCard extends StatelessWidget {
  const _TotalSpentCard({required this.insights});

  final MonthlyInsights insights;

  @override
  Widget build(BuildContext context) {
    final change = insights.changeVsPreviousMonth;
    final previous = DateTime(insights.month.year, insights.month.month - 1);
    return _StatCard(
      label: 'Total spent',
      value: Formatters.wholeAmount(insights.totalSpent),
      dark: true,
      footer: change == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      change <= 0
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 13,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${change.abs().round()}% vs ${Formatters.shortMonth(previous)}',
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BudgetLeftCard extends StatelessWidget {
  const _BudgetLeftCard({required this.insights});

  final MonthlyInsights insights;

  @override
  Widget build(BuildContext context) {
    final over = insights.isOverBudget;
    final daysLeft = insights.daysLeft;
    final footer = switch (daysLeft) {
      null => 'Month ended',
      0 => 'Last day',
      1 => '1 day to go',
      final n => '$n days to go',
    };
    if (!insights.hasBudget) {
      return _StatCard(
        label: 'Budget left',
        value: '—',
        dark: false,
        footer: Text(
          'No budget set',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
        ),
      );
    }
    return _StatCard(
      label: over ? 'Over budget' : 'Budget left',
      value: Formatters.wholeAmount(insights.budgetLeft.abs()),
      valueColor: over ? context.colors.danger : null,
      dark: false,
      footer: Text(
        footer,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
      ),
    );
  }
}
