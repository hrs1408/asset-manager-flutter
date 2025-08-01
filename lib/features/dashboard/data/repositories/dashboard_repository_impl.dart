import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/category_expense.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../../../../core/services/connectivity_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, AssetSummary>> getAssetSummary(String userId) async {
    try {
      // Try to get from remote first
      if (await connectivityService.isConnected) {
        try {
          final remoteAssetSummary = await remoteDataSource.getAssetSummary(userId);
          // Cache the result locally
          await localDataSource.cacheAssetSummary(remoteAssetSummary);
          return Right(remoteAssetSummary);
        } catch (e) {
          // If remote fails, try local cache
          final cachedAssetSummary = await localDataSource.getCachedAssetSummary(userId);
          if (cachedAssetSummary != null) {
            return Right(cachedAssetSummary);
          }
          return Left(ServerFailure('Failed to get asset summary: $e'));
        }
      } else {
        // No internet, use cached data
        final cachedAssetSummary = await localDataSource.getCachedAssetSummary(userId);
        if (cachedAssetSummary != null) {
          return Right(cachedAssetSummary);
        }
        return Left(CacheFailure('No cached asset summary available'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (await connectivityService.isConnected) {
        try {
          final remoteExpenseSummary = await remoteDataSource.getExpenseSummary(
            userId,
            startDate,
            endDate,
          );
          await localDataSource.cacheExpenseSummary(remoteExpenseSummary);
          return Right(remoteExpenseSummary);
        } catch (e) {
          final cachedExpenseSummary = await localDataSource.getCachedExpenseSummary(
            userId,
            startDate,
            endDate,
          );
          if (cachedExpenseSummary != null) {
            return Right(cachedExpenseSummary);
          }
          return Left(ServerFailure('Failed to get expense summary: $e'));
        }
      } else {
        final cachedExpenseSummary = await localDataSource.getCachedExpenseSummary(
          userId,
          startDate,
          endDate,
        );
        if (cachedExpenseSummary != null) {
          return Right(cachedExpenseSummary);
        }
        return Left(CacheFailure('No cached expense summary available'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryExpense>>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeZeroExpenses = false,
    int? limit,
  }) async {
    try {
      if (await connectivityService.isConnected) {
        try {
          final remoteCategoryExpenses = await remoteDataSource.getExpensesByCategory(
            userId,
            startDate,
            endDate,
            includeZeroExpenses: includeZeroExpenses,
            limit: limit,
          );
          await localDataSource.cacheCategoryExpenses(remoteCategoryExpenses);
          return Right(remoteCategoryExpenses);
        } catch (e) {
          final cachedCategoryExpenses = await localDataSource.getCachedCategoryExpenses(
            userId,
            startDate,
            endDate,
          );
          if (cachedCategoryExpenses != null) {
            return Right(cachedCategoryExpenses);
          }
          return Left(ServerFailure('Failed to get category expenses: $e'));
        }
      } else {
        final cachedCategoryExpenses = await localDataSource.getCachedCategoryExpenses(
          userId,
          startDate,
          endDate,
        );
        if (cachedCategoryExpenses != null) {
          return Right(cachedCategoryExpenses);
        }
        return Left(CacheFailure('No cached category expenses available'));
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}