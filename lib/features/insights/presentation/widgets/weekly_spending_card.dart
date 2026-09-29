import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/monthly_insights.dart';

/// Column chart of 7-day spending blocks, in thousands. The busiest block is
/// emphasised; tap any bar for its exact amount.
class WeeklySpendingCard extends StatelessWidget {
  const WeeklySpendingCard({super.key, required this.weeks});

  final List<WeeklySpend> weeks;

  static const double _plotHeight = 120;

  @override
  Widget build(BuildContext context) {
    final max = weeks.fold<double>(0, (m, w) => math.max(m, w.amount));
    final peakIndex = max <= 0 ? -1 : weeks.indexWhere((w) => w.amount == max);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'Weekly spending',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${context.currency}, thousands',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (max <= 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No spending recorded this month.',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            )
          else ...[
            SizedBox(
              height: _plotHeight + 26,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < weeks.length; i++)
                    Expanded(
                      child: _Bar(
                        week: weeks[i],
                        fraction: weeks[i].amount / max,
                        isPeak: i == peakIndex,
                        maxHeight: _plotHeight,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < weeks.length; i++)
                  Expanded(
                    child: Text(
                      '${weeks[i].startDay}–${weeks[i].endDay}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: i == peakIndex
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                        fontWeight: i == peakIndex
                            ? FontWeight.w800
                            : FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.week,
    required this.fraction,
    required this.isPeak,
    required this.maxHeight,
  });

  final WeeklySpend week;
  final double fraction;
  final bool isPeak;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final exact =
        '${context.currency} ${Formatters.amount(week.amount)} '
        '· days ${week.startDay}–${week.endDay}';
    return Semantics(
      label: 'Days ${week.startDay} to ${week.endDay}: $exact',
      excludeSemantics: true,
      child: Tooltip(
        message: exact,
        triggerMode: TooltipTriggerMode.tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (week.amount / 1000).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    color: isPeak
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                    fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Container(
                  width: double.infinity,
                  // Keep a visible sliver for tiny non-zero weeks.
                  height: week.amount > 0 ? math.max(value * maxHeight, 3) : 0,
                  decoration: BoxDecoration(
                    color: isPeak
                        ? context.colors.primaryText
                        : context.colors.primaryMuted,
                    // Rounded data end, square at the baseline.
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
