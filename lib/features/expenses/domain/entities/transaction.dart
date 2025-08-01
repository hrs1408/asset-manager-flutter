import 'package:equatable/equatable.dart';
import 'transaction_type.dart';
import 'deposit_source.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String assetId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final TransactionType type;
  final DepositSource? depositSource; // Chỉ có khi type = deposit
  final String? toAssetId; // Chỉ có khi type = transfer
  final String? notes; // Ghi chú thêm

  const Transaction({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    this.type = TransactionType.expense,
    this.depositSource,
    this.toAssetId,
    this.notes,
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
    TransactionType? type,
    DepositSource? depositSource,
    String? toAssetId,
    String? notes,
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
      type: type ?? this.type,
      depositSource: depositSource ?? this.depositSource,
      toAssetId: toAssetId ?? this.toAssetId,
      notes: notes ?? this.notes,
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
        type,
        depositSource,
        toAssetId,
        notes,
      ];
}