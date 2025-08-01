import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// Tạo giao dịch mới
  Future<Either<Failure, Transaction>> createTransaction(Transaction transaction);

  /// Lấy danh sách giao dịch của người dùng
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId);

  /// Lấy giao dịch theo ID
  Future<Either<Failure, Transaction>> getTransactionById(String transactionId);

  /// Cập nhật thông tin giao dịch
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  /// Xóa giao dịch
  Future<Either<Failure, void>> deleteTransaction(String transactionId);

  /// Lấy giao dịch theo tài sản
  Future<Either<Failure, List<Transaction>>> getTransactionsByAsset(String assetId);

  /// Lấy giao dịch theo danh mục
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(String categoryId);

  /// Lấy giao dịch trong khoảng thời gian
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Lấy tổng chi tiêu theo danh mục trong khoảng thời gian
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Lấy tổng chi tiêu theo tài sản trong khoảng thời gian
  Future<Either<Failure, Map<String, double>>> getExpensesByAsset(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Lấy tổng chi tiêu theo ngày trong khoảng thời gian
  Future<Either<Failure, Map<DateTime, double>>> getDailyExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}