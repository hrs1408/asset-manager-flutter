import 'package:equatable/equatable.dart';
import 'asset_type.dart';

class Asset extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AssetType type;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  Asset copyWith({
    String? id,
    String? userId,
    String? name,
    AssetType? type,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        balance,
        createdAt,
        updatedAt,
      ];
}