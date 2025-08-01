import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../../../expenses/domain/repositories/category_repository.dart';
import '../../../expenses/domain/repositories/transaction_repository.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../entities/export_data.dart';

class ExportDataUseCase {
  final AssetRepository assetRepository;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  ExportDataUseCase({
    required this.assetRepository,
    required this.categoryRepository,
    required this.transactionRepository,
    required this.getCurrentUserUseCase,
  });

  Future<Either<Failure, ExportData>> call() async {
    try {
      // Get current user
      final userResult = await getCurrentUserUseCase(NoParams());
      if (userResult.isLeft()) {
        return Left(AuthFailure('User not authenticated'));
      }

      final user = userResult.getOrElse(() => throw Exception());
      if (user == null) {
        return const Left(AuthFailure('User not found'));
      }

      // Get all user data
      final assetsResult = await assetRepository.getAssets(user.id);
      final categoriesResult = await categoryRepository.getCategories(user.id);
      final transactionsResult = await transactionRepository.getTransactions(user.id);

      if (assetsResult.isLeft()) {
        return Left(assetsResult.fold((l) => l, (r) => throw Exception()));
      }
      if (categoriesResult.isLeft()) {
        return Left(categoriesResult.fold((l) => l, (r) => throw Exception()));
      }
      if (transactionsResult.isLeft()) {
        return Left(transactionsResult.fold((l) => l, (r) => throw Exception()));
      }

      final assets = assetsResult.getOrElse(() => []);
      final categories = categoriesResult.getOrElse(() => []);
      final transactions = transactionsResult.getOrElse(() => []);

      final exportData = ExportData(
        userId: user.id,
        userEmail: user.email ?? '',
        exportDate: DateTime.now(),
        assets: assets,
        categories: categories,
        transactions: transactions,
      );

      return Right(exportData);
    } catch (e) {
      return Left(ServerFailure('Failed to export data: ${e.toString()}'));
    }
  }
}