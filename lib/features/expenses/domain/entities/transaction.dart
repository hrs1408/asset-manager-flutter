import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String assetId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? assetId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        assetId,
        categoryId,
        amount,
        description,
        date,
        createdAt,
      ];
}