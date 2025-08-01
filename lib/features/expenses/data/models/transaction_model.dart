import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;

class TransactionModel extends domain.Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.assetId,
    required super.categoryId,
    required super.amount,
    required super.description,
    required super.date,
    required super.createdAt,
  });

  /// Tạo TransactionModel từ Transaction entity
  factory TransactionModel.fromEntity(domain.Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      assetId: transaction.assetId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      description: transaction.description,
      date: transaction.date,
      createdAt: transaction.createdAt,
    );
  }

  /// Tạo TransactionModel từ Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      assetId: data['assetId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo TransactionModel từ Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      assetId: map['assetId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Chuyển đổi thành Map để update Firestore (không có createdAt)
  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() => toMap();

  /// Tạo TransactionModel từ JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel.fromMap(json);

  /// Tạo copy với các thuộc tính mới
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? assetId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assetId: assetId ?? this.assetId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Chuyển đổi thành Transaction entity
  domain.Transaction toEntity() {
    return domain.Transaction(
      id: id,
      userId: userId,
      assetId: assetId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
      createdAt: createdAt,
    );
  }
}