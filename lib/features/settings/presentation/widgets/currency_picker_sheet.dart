import 'package:flutter/material.dart';

import '../../../../core/currency/currency.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet listing [Currency.supported]. Returns the pick, or null.
Future<Currency?> showCurrencyPicker(
  BuildContext context, {
  required Currency selected,
}) {
  return showModalBottomSheet<Currency>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(
                'Currency',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Changes the label on every amount. Existing amounts are '
                'not converted.',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final currency in Currency.supported)
                    _CurrencyTile(
                      currency: currency,
                      selected: currency == selected,
                      onTap: () => Navigator.pop(context, currency),
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

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final Currency currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      selected: selected,
      onTap: onTap,
      leading: Container(
        width: 52,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary
              : context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          currency.code,
          style: TextStyle(
            color: selected
                ? AppColors.textOnPrimary
                : context.colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      title: Text(
        currency.name,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: context.colors.primaryText)
          : null,
    );
  }
}
