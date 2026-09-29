import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/utils/category_style.dart';
import '../../domain/entities/history_filter.dart';

/// Opens the "Filter expenses" sheet. Returns the chosen filter, or null if
/// the sheet was dismissed.
///
/// [countMatching] is used to preview how many expenses a filter would show.
Future<HistoryFilter?> showFilterExpensesSheet(
  BuildContext context, {
  required HistoryFilter initial,
  required DateTime now,
  required Future<int> Function(HistoryFilter filter) countMatching,
}) {
  return showModalBottomSheet<HistoryFilter>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: _FilterExpensesSheet(
        initial: initial,
        now: now,
        countMatching: countMatching,
      ),
    ),
  );
}

class _FilterExpensesSheet extends StatefulWidget {
  const _FilterExpensesSheet({
    required this.initial,
    required this.now,
    required this.countMatching,
  });

  final HistoryFilter initial;
  final DateTime now;
  final Future<int> Function(HistoryFilter filter) countMatching;

  @override
  State<_FilterExpensesSheet> createState() => _FilterExpensesSheetState();
}

class _FilterExpensesSheetState extends State<_FilterExpensesSheet> {
  late HistoryFilter _draft = widget.initial;
  int? _count;
  int _countRequest = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  void _update(HistoryFilter draft) {
    setState(() => _draft = draft);
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    final request = ++_countRequest;
    final count = await widget.countMatching(_draft);
    if (mounted && request == _countRequest) setState(() => _count = count);
  }

  void _toggleCategory(ExpenseCategory category) {
    final categories = {..._draft.categories};
    if (!categories.remove(category)) categories.add(category);
    _update(_draft.copyWith(categories: categories));
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _draft.from : _draft.to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(widget.now.year - 5),
      lastDate: DateTime(widget.now.year + 1, 12, 31),
      helpText: isFrom ? 'From date' : 'To date',
    );
    if (picked == null) return;
    _update(
      isFrom
          ? _draft.withCustomRange(from: picked)
          : _draft.withCustomRange(to: picked),
    );
  }

  void _reset() =>
      _update(HistoryFilter.initial(widget.now).copyWith(query: _draft.query));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter expenses',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.danger,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionLabel('Category'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final category in context.categories)
                        _CategoryChip(
                          category: category,
                          selected: _draft.categories.contains(category),
                          onTap: () => _toggleCategory(category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionLabel('Date'),
                  _PresetSelector(
                    selected: _draft.preset,
                    onChanged: (preset) =>
                        _update(_draft.withPreset(preset, widget.now)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateBox(
                          label: 'From',
                          date: _draft.from,
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateBox(
                          label: 'To',
                          date: _draft.to,
                          onTap: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionLabel('Sort by'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sort in ExpenseSort.values)
                        _SortChip(
                          label: switch (sort) {
                            ExpenseSort.newestFirst => 'Newest first',
                            ExpenseSort.oldestFirst => 'Oldest first',
                            ExpenseSort.highestAmount => 'Highest amount',
                          },
                          selected: _draft.sort == sort,
                          onTap: () => _update(_draft.copyWith(sort: sort)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _draft),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(switch (_count) {
                null => 'Show expenses',
                1 => 'Show 1 expense',
                final n => 'Show $n expenses',
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final radius = BorderRadius.circular(14);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.12)
            : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? color.withValues(alpha: 0.7)
                : context.colors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Icon(Icons.check_rounded, size: 18, color: color)
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                SizedBox(width: selected ? 8 : 10),
                Text(
                  category.label,
                  style: TextStyle(
                    color: selected ? color : context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.selected, required this.onChanged});

  final DateRangePreset selected;
  final ValueChanged<DateRangePreset> onChanged;

  static String _label(DateRangePreset preset) => switch (preset) {
    DateRangePreset.thisMonth => 'This month',
    DateRangePreset.lastMonth => 'Last month',
    DateRangePreset.last3Months => '3 months',
    DateRangePreset.custom => 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final preset in DateRangePreset.values)
              Expanded(
                child: _PresetOption(
                  label: _label(preset),
                  selected: preset == selected,
                  onTap: () => onChanged(preset),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PresetOption extends StatelessWidget {
  const _PresetOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? context.colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

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
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Formatters.dayMonthYear(date),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? context.colors.primary : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? context.colors.primary : context.colors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
