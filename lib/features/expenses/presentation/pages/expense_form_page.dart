import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../controllers/expense_form_controller.dart';
import '../expense_form_result.dart';
import '../utils/category_style.dart';
import '../widgets/category_picker.dart';
import '../widgets/delete_expense_dialog.dart';

/// Create a new expense, or edit/delete [expense] when given.
/// Pops with an [ExpenseFormResult], or null if the user backed out.
class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key, this.expense});

  final Expense? expense;

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  late final ExpenseFormController _controller = InjectionContainer.instance
      .expenseFormController(widget.expense);

  late final TextEditingController _amountText = TextEditingController(
    text: widget.expense == null
        ? ''
        : Formatters.amount(widget.expense!.amount),
  );
  late final TextEditingController _titleText = TextEditingController(
    text: widget.expense?.title,
  );
  late final TextEditingController _noteText = TextEditingController(
    text: widget.expense?.note,
  );
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(_onAmountFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountText.dispose();
    _titleText.dispose();
    _noteText.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  /// Tidies "2,450" into "2,450.00" when leaving the field.
  void _onAmountFocusChanged() {
    final amount = _controller.amount;
    if (!_amountFocus.hasFocus && amount != null && amount > 0) {
      _amountText.text = Formatters.amount(amount);
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = _controller.now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) _controller.setDay(picked);
  }

  Future<void> _pickCategory() async {
    FocusScope.of(context).unfocus();
    final category = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      backgroundColor: context.colors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              CategoryPicker(
                selected: _controller.category,
                onChanged: (c) => Navigator.pop(context, c),
              ),
            ],
          ),
        ),
      ),
    );
    if (category != null) _controller.setCategory(category);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final saved = await _controller.save();
    if (saved != null && mounted) {
      Navigator.pop(
        context,
        ExpenseSaved(saved, isNew: !_controller.isEditing),
      );
    }
  }

  Future<void> _delete() async {
    final expense = _controller.initial!;
    FocusScope.of(context).unfocus();
    if (!await showDeleteExpenseDialog(context, expense)) return;
    if (await _controller.delete() && mounted) {
      Navigator.pop(context, ExpenseDeleted(expense));
    }
  }

  /// Close/back/cancel: checks the controller directly rather than relying
  /// on PopScope, whose canPop only updates on the next rebuild.
  void _close() {
    if (_controller.isDirty) {
      _confirmDiscard();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes to this expense will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => PopScope(
        canPop: !_controller.isDirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmDiscard();
        },
        // Own messenger so snackbars from other screens can't cover the
        // bottom buttons.
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    title: _controller.isEditing
                        ? 'Edit expense'
                        : 'New expense',
                    leadingIcon: _controller.isEditing
                        ? Icons.arrow_back_rounded
                        : Icons.close_rounded,
                    leadingLabel: _controller.isEditing ? 'Back' : 'Close',
                    onLeading: _close,
                    onDelete: _controller.isEditing ? _delete : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: _buildForm(),
                    ),
                  ),
                  _BottomBar(
                    isEditing: _controller.isEditing,
                    isBusy: _controller.isBusy,
                    errorCount: _controller.errorCount,
                    actionError: _controller.actionError,
                    onSave: _save,
                    onCancel: _close,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final c = _controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmountField(
          controller: _amountText,
          focusNode: _amountFocus,
          autofocus: !c.isEditing,
          error: c.amountError,
          onChanged: (text) => c.setAmount(AmountInputFormatter.parse(text)),
        ),
        const SizedBox(height: 26),
        const _FieldLabel('Title'),
        TextField(
          controller: _titleText,
          onChanged: c.setTitle,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            context,
            hint: 'e.g. Lunch with team',
            hasError: c.titleError != null,
          ),
        ),
        if (c.titleError != null) _FieldError(c.titleError!),
        const SizedBox(height: 20),
        if (c.isEditing)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('Category'),
                    _CategorySelectField(
                      category: c.category!,
                      onTap: _pickCategory,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('Date'),
                    _DateField(
                      label: Formatters.dayMonthYear(c.date),
                      compact: true,
                      onTap: _pickDate,
                    ),
                  ],
                ),
              ),
            ],
          )
        else ...[
          const _FieldLabel('Category'),
          _CategoryGrid(
            selected: c.category,
            hasError: c.categoryError != null,
            onChanged: c.setCategory,
          ),
          if (c.categoryError != null) _FieldError(c.categoryError!),
          const SizedBox(height: 20),
          const _FieldLabel('Date'),
          _DateField(label: _relativeDateLabel(c), onTap: _pickDate),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: _FieldLabel('Note', hint: ' (optional)')),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${c.note.length}/${ExpenseFormController.maxNoteLength}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        TextField(
          controller: _noteText,
          onChanged: c.setNote,
          minLines: 3,
          maxLines: 5,
          maxLength: ExpenseFormController.maxNoteLength,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            context,
            hint: 'Add a note...',
          ).copyWith(counterText: ''),
        ),
        if (c.initial?.createdAt case final createdAt?) ...[
          const SizedBox(height: 16),
          _InfoStrip(createdAt: createdAt),
        ],
      ],
    );
  }

  static String _relativeDateLabel(ExpenseFormController c) {
    final prefix = switch (Formatters.daysAgo(c.date, now: c.now)) {
      0 => 'Today, ',
      1 => 'Yesterday, ',
      _ => '',
    };
    return '$prefix${Formatters.weekdayDayMonthYear(c.date)}';
  }

  static InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    bool hasError = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.colors.textSecondary),
      filled: true,
      fillColor: hasError
          ? context.colors.dangerSurface
          : context.colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(
        hasError ? context.colors.danger : context.colors.border,
      ),
      focusedBorder: border(
        hasError ? context.colors.danger : context.colors.primaryText,
        1.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────── Header ──

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.leadingIcon,
    required this.leadingLabel,
    required this.onLeading,
    this.onDelete,
  });

  final String title;
  final IconData leadingIcon;
  final String leadingLabel;
  final VoidCallback onLeading;

  /// Shows a delete button when set.
  final VoidCallback? onDelete;

  static const double _buttonSize = 46;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _SquareButton(
            icon: leadingIcon,
            label: leadingLabel,
            onTap: onLeading,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          if (onDelete != null)
            _SquareButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete expense',
              onTap: onDelete!,
              color: context.colors.danger,
              background: context.colors.dangerSurface,
              border: context.colors.dangerBorder,
            )
          else
            const SizedBox(width: _buttonSize),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.background,
    this.border,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Defaults to the theme's text, surface and border colours.
  final Color? color;
  final Color? background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Tooltip(
      message: label,
      child: Material(
        color: background ?? context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border ?? context.colors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            width: _Header._buttonSize,
            height: _Header._buttonSize,
            child: Icon(icon, color: color ?? context.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────── Fields ──

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onChanged,
    this.error,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final amountColor = hasError
        ? context.colors.danger
        : context.colors.textPrimary;
    final amountStyle = TextStyle(
      fontSize: 46,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      color: amountColor,
    );
    final underline = UnderlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? context.colors.danger : context.colors.primaryText,
        width: 2,
      ),
    );

    return Column(
      children: [
        Text(
          'Amount',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              context.currency,
              style: TextStyle(
                color: hasError
                    ? context.colors.danger
                    : context.colors.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [AmountInputFormatter()],
                    textAlign: TextAlign.center,
                    style: amountStyle,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: amountStyle.copyWith(
                        color: hasError
                            ? context.colors.danger
                            : context.colors.textSecondary.withValues(
                                alpha: 0.4,
                              ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 6),
                      enabledBorder: underline,
                      focusedBorder: underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ErrorLine(error!, center: true),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          children: [
            if (hint != null)
              TextSpan(
                text: hint,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 2),
      child: _ErrorLine(message),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine(this.message, {this.center = false});

  final String message;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 17,
          color: context.colors.danger,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            style: TextStyle(color: context.colors.danger, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.hasError,
    required this.onChanged,
  });

  final ExpenseCategory? selected;
  final bool hasError;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final picker = CategoryPicker(selected: selected, onChanged: onChanged);
    if (!hasError) return picker;
    return DashedBorder(
      color: context.colors.danger.withValues(alpha: 0.6),
      radius: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.dangerSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: picker,
      ),
    );
  }
}

/// Compact "dropdown" showing the chosen category (edit mode).
class _CategorySelectField extends StatelessWidget {
  const _CategorySelectField({required this.category, required this.onTap});

  final ExpenseCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final radius = BorderRadius.circular(16);
    return Material(
      color: color.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: color.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;

  /// Compact: no dropdown chevron, sized to sit next to another field.
  final bool compact;

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
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 17 : 16,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: context.colors.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!compact)
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.colors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.createdAt});

  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_android_rounded,
            size: 18,
            color: AppColors.bills,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saved on this device · Added '
              '${Formatters.dayMonth(createdAt)}, ${Formatters.time12h(createdAt)}',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Bottom bar ──

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isEditing,
    required this.isBusy,
    required this.errorCount,
    required this.onSave,
    required this.onCancel,
    this.actionError,
  });

  final bool isEditing;
  final bool isBusy;
  final int errorCount;
  final String? actionError;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    const textStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

    final save = FilledButton(
      onPressed: isBusy ? null : onSave,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.7),
        minimumSize: const Size.fromHeight(58),
        shape: shape,
        textStyle: textStyle,
      ),
      child: isBusy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            )
          : Text(isEditing ? 'Save changes' : 'Save expense'),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorCount > 0)
            _Banner(
              'Fix $errorCount ${errorCount == 1 ? 'field' : 'fields'} '
              'to save this expense',
            )
          else if (actionError != null)
            _Banner(actionError!),
          if (isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textPrimary,
                      backgroundColor: context.colors.surface,
                      minimumSize: const Size.fromHeight(58),
                      side: BorderSide(color: context.colors.border),
                      shape: shape,
                      // Smaller than Save so the primary action stands out.
                      textStyle: textStyle.copyWith(fontSize: 15),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: save),
              ],
            )
          else
            SizedBox(width: double.infinity, child: save),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.errorBanner,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: Color(0xFFF08C86),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
