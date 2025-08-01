import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String userId;
  final TransactionFilter? filter;

  const LoadTransactions({
    required this.userId,
    this.filter,
  });

  @override
  List<Object?> get props => [userId, filter];
}

class CreateTransaction extends TransactionEvent {
  final Transaction transaction;

  const CreateTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;

  const DeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class FilterTransactions extends TransactionEvent {
  final TransactionFilter filter;

  const FilterTransactions({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class SearchTransactions extends TransactionEvent {
  final String query;

  const SearchTransactions({required this.query});

  @override
  List<Object?> get props => [query];
}

class ClearTransactionFilters extends TransactionEvent {
  const ClearTransactionFilters();
}

class RefreshTransactions extends TransactionEvent {
  final String userId;

  const RefreshTransactions({required this.userId});

  @override
  List<Object?> get props => [userId];
}