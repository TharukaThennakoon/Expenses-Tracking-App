import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/month_picker_sheet.dart';

/// White pill showing the month ("September 2026 ⌄"); opens a month list.
class MonthPickerButton extends StatelessWidget {
  const MonthPickerButton({
    super.key,
    required this.month,
    required this.months,
    required this.onChanged,
  });

  final DateTime month;
  final List<DateTime> months;
  final ValueChanged<DateTime> onChanged;

  Future<void> _open(BuildContext context) async {
    final picked = await showMonthPickerSheet(
      context,
      selected: month,
      months: months,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.colors.border),
      ),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  Formatters.monthYear(month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
