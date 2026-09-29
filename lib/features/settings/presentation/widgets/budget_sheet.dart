import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/utils/formatters.dart';

/// What the user chose in [showBudgetSheet].
class BudgetChange {
  const BudgetChange(this.budget);

  /// The new budget, or null to remove it.
  final double? budget;
}

/// Lets the user set, change or remove the monthly budget.
/// Returns null if they closed the sheet without saving.
Future<BudgetChange?> showBudgetSheet(
  BuildContext context, {
  required double? current,
}) {
  return showModalBottomSheet<BudgetChange>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _BudgetSheet(current: current),
  );
}

class _BudgetSheet extends StatefulWidget {
  const _BudgetSheet({required this.current});

  final double? current;

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (widget.current) {
      null => '',
      final b when b == b.truncateToDouble() => Formatters.wholeAmount(b),
      final b => Formatters.amount(b),
    },
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final amount = AmountInputFormatter.parse(_controller.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    Navigator.pop(context, BudgetChange(amount));
  }

  @override
  Widget build(BuildContext context) {
    final hasBudget = widget.current != null;
    return Padding(
      // Keep the field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Monthly budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Home and Insights track your spending against this.',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [AmountInputFormatter()],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  prefixText: '${context.currency}  ',
                  prefixStyle: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: '0',
                  errorText: _error,
                  filled: true,
                  fillColor: context.colors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(hasBudget ? 'Save budget' : 'Set budget'),
                ),
              ),
              if (hasBudget) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const BudgetChange(null)),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.danger,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Remove budget'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
