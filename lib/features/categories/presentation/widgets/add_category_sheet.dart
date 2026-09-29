import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/utils/category_style.dart';
import '../../../expenses/presentation/widgets/category_icon.dart';
import '../../domain/usecases/category_usecases.dart';
import '../controllers/categories_controller.dart';

/// Form for a new category: name, icon and colour, with a live preview.
/// Returns the saved category, or null if cancelled.
Future<ExpenseCategory?> showAddCategorySheet(
  BuildContext context, {
  required CategoriesController controller,
}) {
  return showModalBottomSheet<ExpenseCategory>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AddCategorySheet(controller: controller),
  );
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet({required this.controller});

  final CategoriesController controller;

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final TextEditingController _name = TextEditingController();
  String _iconKey = 'home';
  String _colorKey = 'purple';
  String? _error;
  bool _saving = false;

  ExpenseCategory get _draft => ExpenseCategory(
    id: '',
    label: _name.text.trim().isEmpty ? 'New category' : _name.text.trim(),
    iconKey: _iconKey,
    colorKey: _colorKey,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = widget.controller.validateLabel(_name.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await widget.controller.add(
        ExpenseCategory(
          id: '',
          label: _name.text,
          iconKey: _iconKey,
          colorKey: _colorKey,
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } on CategoryValidationException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[_colorKey]!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CategoryIcon(category: _draft, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _name,
                        autofocus: true,
                        maxLength: AddCategory.maxLabelLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                        onChanged: (_) => setState(() => _error = null),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Name, e.g. Rent',
                          errorText: _error,
                          counterText: '',
                          filled: true,
                          fillColor: context.colors.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _Label('Icon'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final entry in categoryIcons.entries)
                      _Choice(
                        selected: entry.key == _iconKey,
                        selectedColor: color,
                        semanticLabel: '${entry.key} icon',
                        onTap: () => setState(() => _iconKey = entry.key),
                        child: Icon(entry.value, size: 22, color: color),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                const _Label('Colour'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final entry in categoryColors.entries)
                      _Choice(
                        selected: entry.key == _colorKey,
                        selectedColor: entry.value,
                        semanticLabel: '${entry.key} colour',
                        onTap: () => setState(() => _colorKey = entry.key),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: entry.value,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
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
                    child: const Text('Add category'),
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Square option tile used for both icons and colours.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.selectedColor,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color selectedColor;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.14)
            : context.colors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(width: 46, height: 46, child: Center(child: child)),
        ),
      ),
    );
  }
}
