import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final CreateTransactionUseCase _createTransactionUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  TransactionBloc({
    required CreateTransactionUseCase createTransactionUseCase,
    required GetTransactionsUseCase getTransactionsUseCase,
    required UpdateTransactionUseCase updateTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  })  : _createTransactionUseCase = createTransactionUseCase,
        _getTransactionsUseCase = getTransactionsUseCase,
        _updateTransactionUseCase = updateTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase,
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
    on<SearchTransactions>(_onSearchTransactions);
    on<ClearTransactionFilters>(_onClearTransactionFilters);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await _getTransactionsUseCase(
      event.userId,
      filter: event.filter,
    );

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transactions) {
        // Sort transactions by date (newest first)
        transactions.sort((a, b) => b.date.compareTo(a.date));
        
        emit(TransactionLoaded(
          transactions: transactions,
          filteredTransactions: transactions,
          currentFilter: event.filter,
          isFiltered: event.filter != null,
        ));
      },
    );
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionCreating());

    final result = await _createTransactionUseCase(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transaction) {
        emit(TransactionCreated(transaction: transaction));
        
        // Reload transactions after creation
        add(LoadTransactions(userId: transaction.userId));
      },
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionUpdating());

    final result = await _updateTransactionUseCase(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transaction) {
        emit(TransactionUpdated(transaction: transaction));
        
        // Reload transactions after update
        add(LoadTransactions(userId: transaction.userId));
      },
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionDeleting());

    final result = await _deleteTransactionUseCase(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (_) {
        emit(TransactionDeleted(transactionId: event.transactionId));
        
        // Get current user ID from current state to reload transactions
        if (state is TransactionLoaded) {
          final currentState = state as TransactionLoaded;
          if (currentState.transactions.isNotEmpty) {
            final userId = currentState.transactions.first.userId;
            add(LoadTransactions(userId: userId));
          }
        }
      },
    );
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      
      // Apply filter to existing transactions
      List<Transaction> filteredTransactions = _applyFilter(
        currentState.transactions,
        event.filter,
      );

      // Apply search if there's an active search query
      if (currentState.searchQuery != null && currentState.searchQuery!.isNotEmpty) {
        filteredTransactions = _applySearch(
          filteredTransactions,
          currentState.searchQuery!,
        );
      }

      emit(currentState.copyWith(
        filteredTransactions: filteredTransactions,
        currentFilter: event.filter,
        isFiltered: true,
      ));
    }
  }

  Future<void> _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      
      // Start with filtered transactions if there's an active filter
      List<Transaction> baseTransactions = currentState.isFiltered && currentState.currentFilter != null
          ? _applyFilter(currentState.transactions, currentState.currentFilter!)
          : currentState.transactions;

      // Apply search
      List<Transaction> searchResults = event.query.isEmpty
          ? baseTransactions
          : _applySearch(baseTransactions, event.query);

      emit(currentState.copyWith(
        filteredTransactions: searchResults,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onClearTransactionFilters(
    ClearTransactionFilters event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      
      emit(currentState.copyWith(
        filteredTransactions: currentState.transactions,
        clearFilter: true,
        clearSearch: true,
        isFiltered: false,
      ));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    // Keep current filter and search when refreshing
    TransactionFilter? currentFilter;
    String? searchQuery;
    
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      currentFilter = currentState.currentFilter;
      searchQuery = currentState.searchQuery;
    }

    add(LoadTransactions(
      userId: event.userId,
      filter: currentFilter,
    ));

    // Reapply search if there was one
    if (searchQuery != null && searchQuery.isNotEmpty) {
      add(SearchTransactions(query: searchQuery));
    }
  }

  List<Transaction> _applyFilter(
    List<Transaction> transactions,
    TransactionFilter filter,
  ) {
    List<Transaction> filtered = List.from(transactions);

    // Filter by asset
    if (filter.assetId != null) {
      filtered = filtered
          .where((transaction) => transaction.assetId == filter.assetId!)
          .toList();
    }

    // Filter by category
    if (filter.categoryId != null) {
      filtered = filtered
          .where((transaction) => transaction.categoryId == filter.categoryId!)
          .toList();
    }

    // Filter by date range
    if (filter.startDate != null && filter.endDate != null) {
      filtered = filtered
          .where((transaction) =>
              transaction.date.isAfter(filter.startDate!.subtract(const Duration(days: 1))) &&
              transaction.date.isBefore(filter.endDate!.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }

  List<Transaction> _applySearch(
    List<Transaction> transactions,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    
    return transactions
        .where((transaction) =>
            transaction.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}