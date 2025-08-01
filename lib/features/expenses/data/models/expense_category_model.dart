import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_category.dart';

class ExpenseCategoryModel extends ExpenseCategory {
  const ExpenseCategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.icon,
    required super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Tạo ExpenseCategoryModel từ ExpenseCategory entity
  factory ExpenseCategoryModel.fromEntity(ExpenseCategory category) {
    return ExpenseCategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      description: category.description,
      icon: category.icon,
      isDefault: category.isDefault,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  /// Tạo ExpenseCategoryModel từ Firestore document
  factory ExpenseCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ExpenseCategoryModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '📦',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo ExpenseCategoryModel từ Map
  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '📦',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Chuyển đổi thành Map để update Firestore (không có createdAt)
  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'isDefault': isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() => toMap();

  /// Tạo ExpenseCategoryModel từ JSON
  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) => ExpenseCategoryModel.fromMap(json);

  /// Tạo copy với các thuộc tính mới
  ExpenseCategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseCategoryModel(
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

  /// Chuyển đổi thành ExpenseCategory entity
  ExpenseCategory toEntity() {
    return ExpenseCategory(
      id: id,
      userId: userId,
      name: name,
      description: description,
      icon: icon,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}