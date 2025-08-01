import 'package:equatable/equatable.dart';

class ExpenseCategory extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String icon;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.icon,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        icon,
        isDefault,
        createdAt,
        updatedAt,
      ];

  /// Danh sách các danh mục mặc định
  static List<ExpenseCategory> getDefaultCategories(String userId) {
    final now = DateTime.now();
    return [
      ExpenseCategory(
        id: 'default_food',
        userId: userId,
        name: 'Ăn uống',
        description: 'Chi phí ăn uống hàng ngày',
        icon: '🍽️',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'default_education',
        userId: userId,
        name: 'Giáo dục',
        description: 'Chi phí học tập, sách vở',
        icon: '📚',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'default_travel',
        userId: userId,
        name: 'Du lịch',
        description: 'Chi phí du lịch, nghỉ dưỡng',
        icon: '✈️',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'default_healthcare',
        userId: userId,
        name: 'Y tế',
        description: 'Chi phí khám chữa bệnh',
        icon: '🏥',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'default_shopping',
        userId: userId,
        name: 'Mua sắm',
        description: 'Chi phí mua sắm cá nhân',
        icon: '🛍️',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'default_entertainment',
        userId: userId,
        name: 'Giải trí',
        description: 'Chi phí giải trí, vui chơi',
        icon: '🎮',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}