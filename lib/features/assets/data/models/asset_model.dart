import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Tạo AssetModel từ Asset entity
  factory AssetModel.fromEntity(Asset asset) {
    return AssetModel(
      id: asset.id,
      userId: asset.userId,
      name: asset.name,
      type: asset.type,
      balance: asset.balance,
      createdAt: asset.createdAt,
      updatedAt: asset.updatedAt,
    );
  }

  /// Tạo AssetModel từ Firestore document
  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AssetModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: AssetType.fromString(data['type'] ?? 'other'),
      balance: (data['balance'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo AssetModel từ Map
  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: AssetType.fromString(map['type'] ?? 'other'),
      balance: (map['balance'] ?? 0.0).toDouble(),
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
      'type': type.value,
      'balance': balance,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Chuyển đổi thành Map để update Firestore (không có createdAt)
  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name,
      'type': type.value,
      'balance': balance,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.value,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() => toMap();

  /// Tạo AssetModel từ JSON
  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel.fromMap(json);

  /// Tạo copy với các thuộc tính mới
  AssetModel copyWith({
    String? id,
    String? userId,
    String? name,
    AssetType? type,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Chuyển đổi thành Asset entity
  Asset toEntity() {
    return Asset(
      id: id,
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}