import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/widgets/delete_expense_dialog.dart';
import '../controllers/history_controller.dart';
import '../widgets/empty_history_view.dart';
import '../widgets/expense_group_section.dart';
import '../widgets/filter_expenses_sheet.dart';
import '../widgets/history_filter_chips.dart';
import '../widgets/history_header.dart';
import '../widgets/history_search_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});

  final HistoryController controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  /// Id of the row whose swipe actions are open (null = none).
  final ValueNotifier<Object?> _openTile = ValueNotifier(null);

  HistoryController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Drop filters for categories that were deleted in Settings.
    final available = context.categories.toSet();
    if (_controller.filter.categories.difference(available).isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.setCategories(
        _controller.filter.categories.intersection(available),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _openTile.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    _openTile.value = null;
    final filter = await showFilterExpensesSheet(
      context,
      initial: _controller.filter,
      now: _controller.now,
      countMatching: _controller.countMatching,
    );
    if (filter != null) _controller.applyFilter(filter);
  }

  Future<void> _add() async {
    final result = await AppRoutes.openExpenseForm(context);
    if (result != null) _showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _edit(Expense expense) async {
    final result = await AppRoutes.openExpenseForm(context, expense: expense);
    if (result != null) _showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _delete(Expense expense) async {
    if (!await showDeleteExpenseDialog(context, expense)) return;
    await _controller.deleteExpense(expense);
    _showSnackBar(SnackBar(content: Text('"${expense.title}" deleted')));
  }

  void _showSnackBar(SnackBar snackBar) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.status == HistoryStatus.error) {
          return ErrorStateView(
            title: 'Couldn’t load your expenses',
            error: _controller.error,
            onRetry: _controller.load,
          );
        }
        return SafeArea(
          bottom: false,
          child: _controller.isEmptyMonth ? _buildEmpty() : _buildList(),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: HistoryHeader.month(_controller.filter.from),
        ),
        Expanded(child: EmptyHistoryView(onAddExpense: _add)),
      ],
    );
  }

  Widget _buildList() {
    final filter = _controller.filter;
    final history = _controller.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: HistoryHeader(count: history.count, total: history.total),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: HistorySearchBar(
            controller: _searchController,
            onChanged: _controller.setQuery,
            onFilterTap: _openFilters,
            activeFilterCount: filter.activeCount,
          ),
        ),
        const SizedBox(height: 14),
        HistoryFilterChips(
          filter: filter,
          now: _controller.now,
          onDateTap: _openFilters,
          onAllTap: _controller.clearCategories,
          onRemoveCategory: _controller.removeCategory,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    switch (_controller.status) {
      case HistoryStatus.loading:
        return Center(
          child: CircularProgressIndicator(color: context.colors.primaryText),
        );
      case HistoryStatus.error: // Handled full-screen in build().
      case HistoryStatus.loaded:
        final history = _controller.history;
        if (history.isEmpty) {
          return const _MessageView(
            icon: Icons.receipt_long_outlined,
            title: 'No expenses found',
            subtitle: 'Try another date range, search or filter.',
          );
        }
        return NotificationListener<ScrollStartNotification>(
          onNotification: (_) {
            _openTile.value = null;
            return false;
          },
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            itemCount: history.groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 20),
            itemBuilder: (context, index) => ExpenseGroupSection(
              key: ValueKey(history.groups[index].date),
              group: history.groups[index],
              now: _controller.now,
              openTile: _openTile,
              onEdit: _edit,
              onDelete: _delete,
            ),
          ),
        );
    }
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: context.colors.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
