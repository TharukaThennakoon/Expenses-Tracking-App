import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key, required this.count, required this.total})
    : month = null;

  /// Shows just the month name, for when there is nothing to count.
  const HistoryHeader.month(DateTime this.month, {super.key})
    : count = 0,
      total = 0;

  final int count;
  final double total;
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final bold = TextStyle(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: month != null
                  ? Text(
                      Formatters.monthYear(month!),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: '$count', style: bold),
                          TextSpan(
                            text: count == 1 ? ' expense · ' : ' expenses · ',
                          ),
                          TextSpan(
                            text:
                                '${context.currency} ${Formatters.wholeAmount(total)}',
                            style: bold,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
