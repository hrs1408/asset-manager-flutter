import '../../domain/entities/category_expense.dart';
import '../../../expenses/domain/entities/expense_category.dart';

class CategoryExpenseModel extends CategoryExpense {
  const CategoryExpenseModel({
    required super.category,
    required super.totalAmount,
    required super.transactionCount,
    required super.percentage,
  });

  factory CategoryExpenseModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>;
    final category = ExpenseCategory(
      id: categoryJson['id'] as String,
      userId: categoryJson['userId'] as String,
      name: categoryJson['name'] as String,
      description: categoryJson['description'] as String? ?? '',
      icon: categoryJson['icon'] as String? ?? '📦',
      isDefault: categoryJson['isDefault'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(categoryJson['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(categoryJson['updatedAt'] as int),
    );

    return CategoryExpenseModel(
      category: category,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': {
        'id': category.id,
        'userId': category.userId,
        'name': category.name,
        'description': category.description,
        'icon': category.icon,
        'isDefault': category.isDefault,
        'createdAt': category.createdAt.millisecondsSinceEpoch,
        'updatedAt': category.updatedAt.millisecondsSinceEpoch,
      },
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'percentage': percentage,
    };
  }

  factory CategoryExpenseModel.fromEntity(CategoryExpense entity) {
    return CategoryExpenseModel(
      category: entity.category,
      totalAmount: entity.totalAmount,
      transactionCount: entity.transactionCount,
      percentage: entity.percentage,
    );
  }
}