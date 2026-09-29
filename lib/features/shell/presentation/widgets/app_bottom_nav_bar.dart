import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NavItem {
  const NavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Bottom bar with a gap in the middle for the docked "add" button.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length == 4);

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _buildItem(context, 0),
              _buildItem(context, 1),
              const SizedBox(width: 72),
              _buildItem(context, 2),
              _buildItem(context, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = items[index];
    final selected = index == currentIndex;
    final color = selected
        ? context.colors.primaryText
        : context.colors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: () => onTap(index),
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 24),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddExpenseButton extends StatelessWidget {
  const AddExpenseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: FloatingActionButton(
        onPressed: onPressed,
        // No hero: the FAB is swapped in/out while the keyboard toggles,
        // which would otherwise clash with route transitions.
        heroTag: null,
        backgroundColor: context.colors.primary,
        foregroundColor: AppColors.accent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }
}
