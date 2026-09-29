import '../../../expenses/domain/entities/expense_category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.colorKey,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    label: json['label'] as String,
    iconKey: json['icon'] as String,
    colorKey: json['color'] as String,
  );

  factory CategoryModel.fromEntity(ExpenseCategory category) => CategoryModel(
    id: category.id,
    label: category.label,
    iconKey: category.iconKey,
    colorKey: category.colorKey,
  );

  final String id;
  final String label;
  final String iconKey;
  final String colorKey;

  CategoryModel copyWith({String? id}) => CategoryModel(
    id: id ?? this.id,
    label: label,
    iconKey: iconKey,
    colorKey: colorKey,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': iconKey,
    'color': colorKey,
  };

  ExpenseCategory toEntity() => ExpenseCategory(
    id: id,
    label: label,
    iconKey: iconKey,
    colorKey: colorKey,
  );
}
