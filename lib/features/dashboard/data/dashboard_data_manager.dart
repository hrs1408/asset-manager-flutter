import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/asset_summary.dart';
import '../domain/entities/expense_summary.dart';
import '../domain/entities/category_expense.dart';
import 'demo_dashboard_data.dart';
import 'repositories/dashboard_repository_impl.dart';

enum DataMode {
  demo,
  production,
}

class DashboardDataManager {
  final DashboardRepositoryImpl? _repository;
  final DataMode _mode;

  DashboardDataManager({
    DashboardRepositoryImpl? repository,
    DataMode mode = DataMode.demo,
  }) : _repository = repository, _mode = mode;

  /// Get asset summary based on current mode
  Future<Either<Failure, AssetSummary>> getAssetSummary(String userId) async {
    switch (_mode) {
      case DataMode.demo:
        return Right(DemoDashboardData.getAssetSummary());
      case DataMode.production:
        if (_repository == null) {
          return Left(ServerFailure('Repository not initialized for production mode'));
        }
        return await _repository!.getAssetSummary(userId);
    }
  }

  /// Get expense summary based on current mode
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    switch (_mode) {
      case DataMode.demo:
        return Right(DemoDashboardData.getExpenseSummary());
      case DataMode.production:
        if (_repository == null) {
          return Left(ServerFailure('Repository not initialized for production mode'));
        }
        return await _repository!.getExpenseSummary(userId, startDate, endDate);
    }
  }

  /// Get expenses by category based on current mode
  Future<Either<Failure, List<CategoryExpense>>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeZeroExpenses = false,
    int? limit,
  }) async {
    switch (_mode) {
      case DataMode.demo:
        return Right(DemoDashboardData.getCategoryExpenses());
      case DataMode.production:
        if (_repository == null) {
          return Left(ServerFailure('Repository not initialized for production mode'));
        }
        return await _repository!.getExpensesByCategory(
          userId,
          startDate,
          endDate,
          includeZeroExpenses: includeZeroExpenses,
          limit: limit,
        );
    }
  }

  /// Get recent transactions (demo only for now)
  List<DemoTransaction> getRecentTransactions() {
    return DemoDashboardData.getRecentTransactions();
  }

  /// Check if currently using demo data
  bool get isDemoMode => _mode == DataMode.demo;

  /// Check if currently using production data
  bool get isProductionMode => _mode == DataMode.production;

  /// Get current mode as string
  String get modeString => _mode.toString().split('.').last;
}

/// Factory class to create DashboardDataManager instances
class DashboardDataManagerFactory {
  static DashboardDataManager createDemo() {
    return DashboardDataManager(mode: DataMode.demo);
  }

  static DashboardDataManager createProduction(DashboardRepositoryImpl repository) {
    return DashboardDataManager(
      repository: repository,
      mode: DataMode.production,
    );
  }

  /// Create based on environment or configuration
  static DashboardDataManager createFromConfig({
    bool useDemo = true,
    DashboardRepositoryImpl? repository,
  }) {
    if (useDemo) {
      return createDemo();
    } else {
      if (repository == null) {
        throw ArgumentError('Repository is required for production mode');
      }
      return createProduction(repository);
    }
  }
}