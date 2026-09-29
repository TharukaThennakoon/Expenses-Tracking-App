import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/monthly_summary.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({
    super.key,
    required this.summary,
    required this.onPrevious,
    this.onNext,
    this.onPickMonth,
    this.isCurrentMonth = true,
  });

  final MonthlySummary summary;
  final VoidCallback onPrevious;

  /// Null disables the "next month" arrow.
  final VoidCallback? onNext;

  /// Opens a month list when the month name is tapped.
  final VoidCallback? onPickMonth;

  /// Switches the label between "this month" and the month's name.
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.budgetUsedRatio * 100).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        color: context.colors.primary,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative ring in the top-right corner.
            Positioned(
              right: -90,
              top: -70,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: _MonthSelector(
                        month: summary.month,
                        onPrevious: onPrevious,
                        onNext: onNext,
                        onPick: onPickMonth,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (summary.changeVsPreviousMonth != null)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _ChangeBadge(
                              change: summary.changeVsPreviousMonth!,
                              previousMonth: DateTime(
                                summary.month.year,
                                summary.month.month - 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  isCurrentMonth
                      ? 'Spent this month'
                      : 'Spent in ${Formatters.monthName(summary.month)}',
                  style: const TextStyle(
                    color: AppColors.textOnPrimaryMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _AmountText(amount: summary.totalSpent),
                ),
                const SizedBox(height: 14),
                if (summary.hasBudget) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: summary.budgetUsedRatio),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        color: AppColors.accent,
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Flexible(
                      child: summary.hasBudget
                          ? _FooterText(
                              prefix: '$percent% of ',
                              value:
                                  '${context.currency} ${Formatters.wholeAmount(summary.budget!)}',
                              suffix: ' budget',
                            )
                          : const _FooterText(
                              prefix: '',
                              value: 'No budget set',
                              suffix: '',
                            ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _FooterText(
                          prefix: 'Avg ',
                          value:
                              '${context.currency} ${Formatters.wholeAmount(summary.averagePerDay)}',
                          suffix: '/day',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous month',
            onTap: onPrevious,
          ),
          Flexible(
            child: Semantics(
              button: onPick != null,
              hint: onPick == null ? null : 'Choose month',
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    Formatters.monthYear(month),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Next month',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        // 40x40 so the arrows are easy to hit.
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: onTap == null
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change, required this.previousMonth});

  final double change;
  final DateTime previousMonth;

  @override
  Widget build(BuildContext context) {
    final isDown = change <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDown ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 14,
            color: context.colors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${change.abs().round()}% vs ${Formatters.shortMonth(previousMonth)}',
            style: TextStyle(
              color: context.colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  const _AmountText({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${context.currency} ',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: Formatters.wholeAmount(amount),
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          TextSpan(
            text: Formatters.decimalPart(amount),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText({
    required this.prefix,
    required this.value,
    required this.suffix,
  });

  final String prefix;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            color: AppColors.textOnPrimaryMuted,
            fontSize: 12.5,
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: suffix),
          ],
        ),
      ),
    );
  }
}
