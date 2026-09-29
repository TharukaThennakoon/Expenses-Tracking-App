/// A spending category. The built-in ones are constants below; users can
/// add their own and delete any except [other].
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.colorKey,
  });

  /// Stable identifier stored on expenses.
  final String id;
  final String label;

  /// Keys into the presentation layer's icon and colour choices, so the
  /// domain stays free of Flutter types.
  final String iconKey;
  final String colorKey;

  static const food = ExpenseCategory(
    id: 'food',
    label: 'Food',
    iconKey: 'restaurant',
    colorKey: 'orange',
  );
  static const transport = ExpenseCategory(
    id: 'transport',
    label: 'Transport',
    iconKey: 'bus',
    colorKey: 'blue',
  );
  static const bills = ExpenseCategory(
    id: 'bills',
    label: 'Bills',
    iconKey: 'bolt',
    colorKey: 'teal',
  );
  static const shopping = ExpenseCategory(
    id: 'shopping',
    label: 'Shopping',
    iconKey: 'bag',
    colorKey: 'pink',
  );
  static const health = ExpenseCategory(
    id: 'health',
    label: 'Health',
    iconKey: 'heart',
    colorKey: 'red',
  );
  static const leisure = ExpenseCategory(
    id: 'leisure',
    label: 'Leisure',
    iconKey: 'play',
    colorKey: 'yellow',
  );

  /// Fallback for expenses whose category was deleted. Cannot be deleted.
  static const other = ExpenseCategory(
    id: 'other',
    label: 'Other',
    iconKey: 'category',
    colorKey: 'grey',
  );

  /// The categories a new install starts with, in display order.
  static const List<ExpenseCategory> defaults = [
    food,
    transport,
    bills,
    shopping,
    health,
    leisure,
    other,
  ];

  bool get isDeletable => id != other.id;

  @override
  bool operator ==(Object other) => other is ExpenseCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ExpenseCategory($id)';
}
