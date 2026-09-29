import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/expense_category.dart';

/// Icons a category can use, by the key stored on [ExpenseCategory].
const Map<String, IconData> categoryIcons = {
  'restaurant': Icons.restaurant_rounded,
  'bus': Icons.directions_bus_outlined,
  'bolt': Icons.bolt_rounded,
  'bag': Icons.shopping_bag_outlined,
  'heart': Icons.favorite_border_rounded,
  'play': Icons.play_circle_outline_rounded,
  'home': Icons.home_outlined,
  'school': Icons.school_outlined,
  'coffee': Icons.local_cafe_outlined,
  'fitness': Icons.fitness_center_rounded,
  'pets': Icons.pets_rounded,
  'gift': Icons.card_giftcard_rounded,
  'flight': Icons.flight_rounded,
  'phone': Icons.smartphone_rounded,
  'child': Icons.child_friendly_outlined,
  'savings': Icons.savings_outlined,
  'category': Icons.category_outlined,
};

/// Colours a category can use, by the key stored on [ExpenseCategory].
/// The first seven are the built-in categories' colours.
const Map<String, Color> categoryColors = {
  'orange': AppColors.food,
  'blue': AppColors.transport,
  'teal': AppColors.bills,
  'pink': AppColors.shopping,
  'red': AppColors.health,
  'yellow': AppColors.leisure,
  'grey': AppColors.other,
  'purple': Color(0xFF8A5CD0),
  'green': Color(0xFF4E9A3A),
  'brown': Color(0xFFA86B3C),
};

/// UI-only styling for categories, kept out of the domain layer.
extension CategoryStyle on ExpenseCategory {
  Color get color => categoryColors[colorKey] ?? AppColors.other;

  IconData get icon => categoryIcons[iconKey] ?? Icons.category_outlined;
}
