import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Bottom sheet listing [months] (newest first). Returns the pick, or null.
Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required DateTime selected,
  required List<DateTime> months,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Choose month',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final m in months)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      title: Text(
                        Formatters.monthYear(m),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing:
                          m.year == selected.year && m.month == selected.month
                          ? Icon(
                              Icons.check_rounded,
                              color: context.colors.primaryText,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, m),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
