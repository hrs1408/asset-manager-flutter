import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirestoreService _firestoreService;

  TransactionRepositoryImpl({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<Either<Failure, domain.Transaction>> createTransaction(
    domain.Transaction transaction,
  ) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final docId = await _firestoreService.createDocument(
        AppConstants.transactionsCollection,
        transactionModel.toFirestore(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.transactionsCollection,
        docId,
      );

      final createdTransaction = TransactionModel.fromFirestore(doc);
      return Right(createdTransaction.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactions(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        orderBy: 'date',
        descending: true,
      );

      final transactions = querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Transaction>> getTransactionById(
    String transactionId,
  ) async {
    try {
      final doc = await _firestoreService.getDocument(
        AppConstants.transactionsCollection,
        transactionId,
      );

      if (!doc.exists) {
        return const Left(NotFoundFailure('Transaction not found'));
      }

      final transaction = TransactionModel.fromFirestore(doc);
      return Right(transaction.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Transaction>> updateTransaction(
    domain.Transaction transaction,
  ) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await _firestoreService.updateDocument(
        AppConstants.transactionsCollection,
        transaction.id,
        transactionModel.toFirestoreUpdate(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.transactionsCollection,
        transaction.id,
      );

      final updatedTransaction = TransactionModel.fromFirestore(doc);
      return Right(updatedTransaction.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await _firestoreService.deleteDocument(
        AppConstants.transactionsCollection,
        transactionId,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactionsByAsset(
    String assetId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        field: 'assetId',
        isEqualTo: assetId,
        orderBy: 'date',
        descending: true,
      );

      final transactions = querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactionsByCategory(
    String categoryId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        field: 'categoryId',
        isEqualTo: categoryId,
        orderBy: 'date',
        descending: true,
      );

      final transactions = querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        field: 'date',
        isGreaterThanOrEqualTo: startTimestamp,
      );

      // Filter by end date in memory (Firestore doesn't support multiple range queries)
      final transactions = querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .where((transaction) => 
              transaction.date.isBefore(endDate.add(const Duration(days: 1))))
          .map((model) => model.toEntity())
          .toList();

      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactionsResult = await getTransactionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      if (transactionsResult.isLeft()) {
        return transactionsResult.fold(
          (failure) => Left(failure),
          (_) => const Right({}),
        );
      }

      final transactions = transactionsResult.getOrElse(() => []);
      final Map<String, double> expensesByCategory = {};

      for (final transaction in transactions) {
        final categoryId = transaction.categoryId;
        expensesByCategory[categoryId] = 
            (expensesByCategory[categoryId] ?? 0.0) + transaction.amount;
      }

      return Right(expensesByCategory);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByAsset(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactionsResult = await getTransactionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      if (transactionsResult.isLeft()) {
        return transactionsResult.fold(
          (failure) => Left(failure),
          (_) => const Right({}),
        );
      }

      final transactions = transactionsResult.getOrElse(() => []);
      final Map<String, double> expensesByAsset = {};

      for (final transaction in transactions) {
        final assetId = transaction.assetId;
        expensesByAsset[assetId] = 
            (expensesByAsset[assetId] ?? 0.0) + transaction.amount;
      }

      return Right(expensesByAsset);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, double>>> getDailyExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactionsResult = await getTransactionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      if (transactionsResult.isLeft()) {
        return transactionsResult.fold(
          (failure) => Left(failure),
          (_) => const Right({}),
        );
      }

      final transactions = transactionsResult.getOrElse(() => []);
      final Map<DateTime, double> dailyExpenses = {};

      for (final transaction in transactions) {
        // Normalize date to start of day
        final date = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        
        dailyExpenses[date] = 
            (dailyExpenses[date] ?? 0.0) + transaction.amount;
      }

      return Right(dailyExpenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}