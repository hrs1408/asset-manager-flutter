import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/usecases/usecases.dart';
import '../../../expenses/domain/usecases/get_transactions_usecase.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAssetSummaryUseCase getAssetSummaryUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final GetExpensesByCategoryUseCase getExpensesByCategoryUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;

  DashboardBloc({
    required this.getAssetSummaryUseCase,
    required this.getExpenseSummaryUseCase,
    required this.getExpensesByCategoryUseCase,
    required this.getTransactionsUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<UpdateDateRange>(_onUpdateDateRange);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(event.userId, event.startDate, event.endDate, emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(event.userId, event.startDate, event.endDate, emit);
  }

  Future<void> _onUpdateDateRange(
    UpdateDateRange event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(event.userId, event.startDate, event.endDate, emit);
  }  
Future<void> _loadDashboardData(
    String userId,
    DateTime? startDate,
    DateTime? endDate,
    Emitter<DashboardState> emit,
  ) async {
    try {
      // Set default date range if not provided (last 30 days)
      final now = DateTime.now();
      final defaultStartDate = startDate ?? DateTime(now.year, now.month - 1, now.day);
      final defaultEndDate = endDate ?? now;

      // Load asset summary
      final assetSummaryResult = await getAssetSummaryUseCase(
        GetAssetSummaryParams(userId: userId),
      );

      if (assetSummaryResult.isLeft()) {
        emit(DashboardError(
          message: assetSummaryResult.fold((l) => l.message, (r) => 'Unknown error'),
        ));
        return;
      }

      final assetSummary = assetSummaryResult.getOrElse(() => throw Exception());

      // Load expense summary
      final expenseSummaryResult = await getExpenseSummaryUseCase(
        GetExpenseSummaryParams(
          userId: userId,
          startDate: defaultStartDate,
          endDate: defaultEndDate,
        ),
      );

      if (expenseSummaryResult.isLeft()) {
        emit(DashboardError(
          message: expenseSummaryResult.fold((l) => l.message, (r) => 'Unknown error'),
        ));
        return;
      }

      final expenseSummary = expenseSummaryResult.getOrElse(() => throw Exception());

      // Load expenses by category
      final categoryExpensesResult = await getExpensesByCategoryUseCase(
        GetExpensesByCategoryParams(
          userId: userId,
          startDate: defaultStartDate,
          endDate: defaultEndDate,
          includeZeroExpenses: false,
          limit: 10,
        ),
      );

      if (categoryExpensesResult.isLeft()) {
        emit(DashboardError(
          message: categoryExpensesResult.fold((l) => l.message, (r) => 'Unknown error'),
        ));
        return;
      }

      final categoryExpenses = categoryExpensesResult.getOrElse(() => []);

      // Load recent transactions
      final recentTransactionsResult = await getTransactionsUseCase(
        userId,
        filter: const TransactionFilter(limit: 10),
      );

      if (recentTransactionsResult.isLeft()) {
        emit(DashboardError(
          message: recentTransactionsResult.fold((l) => l.message, (r) => 'Unknown error'),
        ));
        return;
      }

      final recentTransactions = recentTransactionsResult.getOrElse(() => []);

      emit(DashboardLoaded(
        assetSummary: assetSummary,
        expenseSummary: expenseSummary,
        categoryExpenses: categoryExpenses,
        recentTransactions: recentTransactions,
        startDate: defaultStartDate,
        endDate: defaultEndDate,
      ));
    } catch (e) {
      emit(DashboardError(message: 'Lỗi không xác định: $e'));
    }
  }
}