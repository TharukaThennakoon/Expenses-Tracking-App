import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/widgets/category_icon.dart';
import '../controllers/categories_controller.dart';
import '../widgets/add_category_sheet.dart';

/// Lists categories; lets the user add new ones and delete any but "Other".
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key, required this.controller});

  final CategoriesController controller;

  Future<void> _add(BuildContext context) async {
    final added = await showAddCategorySheet(context, controller: controller);
    if (added == null || !context.mounted) return;
    _snack(context, '"${added.label}" added');
  }

  Future<void> _delete(BuildContext context, ExpenseCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${category.label}"?'),
        content: const Text(
          'Expenses in this category will move to Other. '
          'This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.delete(category);
    if (context.mounted) _snack(context, '"${category.label}" deleted');
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final categories = controller.categories;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < categories.length; i++) ...[
                        if (i > 0) const Divider(indent: 16, endIndent: 16),
                        _CategoryRow(
                          category: categories[i],
                          onDelete: categories[i].isDeletable
                              ? () => _delete(context, categories[i])
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Other can’t be deleted — it holds expenses from '
                  'deleted categories.',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _add(context),
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
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.accent,
                    ),
                    label: const Text('Add category'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onDelete});

  final ExpenseCategory category;

  /// Null for categories that can't be deleted.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          CategoryIcon(category: category, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete ${category.label}',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: context.colors.danger,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                'Default',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
