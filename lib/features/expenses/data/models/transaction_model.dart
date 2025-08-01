import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/deposit_source.dart';

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
    super.type = TransactionType.expense,
    super.depositSource,
    super.toAssetId,
    super.notes,
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
      type: transaction.type,
      depositSource: transaction.depositSource,
      toAssetId: transaction.toAssetId,
      notes: transaction.notes,
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
      type: TransactionTypeExtension.fromString(data['type'] ?? 'expense'),
      depositSource: data['depositSource'] != null 
          ? DepositSourceExtension.fromString(data['depositSource'])
          : null,
      toAssetId: data['toAssetId'],
      notes: data['notes'],
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
      type: TransactionTypeExtension.fromString(map['type'] ?? 'expense'),
      depositSource: map['depositSource'] != null 
          ? DepositSourceExtension.fromString(map['depositSource'])
          : null,
      toAssetId: map['toAssetId'],
      notes: map['notes'],
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    final data = {
      'id': id,
      'userId': userId,
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
      'type': type.value,
    };

    if (depositSource != null) {
      data['depositSource'] = depositSource!.value;
    }
    if (toAssetId != null) {
      data['toAssetId'] = toAssetId!;
    }
    if (notes != null) {
      data['notes'] = notes!;
    }

    return data;
  }

  /// Chuyển đổi thành Map để update Firestore (không có createdAt)
  Map<String, dynamic> toFirestoreUpdate() {
    final data = {
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.value,
    };

    if (depositSource != null) {
      data['depositSource'] = depositSource!.value;
    }
    if (toAssetId != null) {
      data['toAssetId'] = toAssetId!;
    }
    if (notes != null) {
      data['notes'] = notes!;
    }

    return data;
  }

  /// Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    final data = {
      'id': id,
      'userId': userId,
      'assetId': assetId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'type': type.value,
    };

    if (depositSource != null) {
      data['depositSource'] = depositSource!.value;
    }
    if (toAssetId != null) {
      data['toAssetId'] = toAssetId!;
    }
    if (notes != null) {
      data['notes'] = notes!;
    }

    return data;
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() => toMap();

  /// Tạo TransactionModel từ JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel.fromMap(json);

  /// Tạo copy với các thuộc tính mới
  @override
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? assetId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    TransactionType? type,
    DepositSource? depositSource,
    String? toAssetId,
    String? notes,
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
      type: type ?? this.type,
      depositSource: depositSource ?? this.depositSource,
      toAssetId: toAssetId ?? this.toAssetId,
      notes: notes ?? this.notes,
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
      type: type,
      depositSource: depositSource,
      toAssetId: toAssetId,
      notes: notes,
    );
  }
}