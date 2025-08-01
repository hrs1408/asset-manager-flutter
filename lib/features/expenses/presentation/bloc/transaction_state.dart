import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final TransactionFilter? currentFilter;
  final String? searchQuery;
  final bool isFiltered;

  const TransactionLoaded({
    required this.transactions,
    required this.filteredTransactions,
    this.currentFilter,
    this.searchQuery,
    this.isFiltered = false,
  });

  @override
  List<Object?> get props => [
        transactions,
        filteredTransactions,
        currentFilter,
        searchQuery,
        isFiltered,
      ];

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    TransactionFilter? currentFilter,
    String? searchQuery,
    bool? isFiltered,
    bool clearFilter = false,
    bool clearSearch = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      currentFilter: clearFilter ? null : (currentFilter ?? this.currentFilter),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      isFiltered: isFiltered ?? this.isFiltered,
    );
  }
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionCreating extends TransactionState {
  const TransactionCreating();
}

class TransactionCreated extends TransactionState {
  final Transaction transaction;

  const TransactionCreated({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdating extends TransactionState {
  const TransactionUpdating();
}

class TransactionUpdated extends TransactionState {
  final Transaction transaction;

  const TransactionUpdated({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleting extends TransactionState {
  const TransactionDeleting();
}

class TransactionDeleted extends TransactionState {
  final String transactionId;

  const TransactionDeleted({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}