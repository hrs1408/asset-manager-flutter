import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_category.dart';

abstract class CategoryRepository {
  /// Tạo danh mục chi tiêu mới
  Future<Either<Failure, ExpenseCategory>> createCategory(ExpenseCategory category);

  /// Lấy danh sách danh mục của người dùng
  Future<Either<Failure, List<ExpenseCategory>>> getCategories(String userId);

  /// Lấy danh mục theo ID
  Future<Either<Failure, ExpenseCategory>> getCategoryById(String categoryId);

  /// Cập nhật thông tin danh mục
  Future<Either<Failure, ExpenseCategory>> updateCategory(ExpenseCategory category);

  /// Xóa danh mục
  Future<Either<Failure, void>> deleteCategory(String categoryId);

  /// Khởi tạo danh mục mặc định cho người dùng mới
  Future<Either<Failure, List<ExpenseCategory>>> initializeDefaultCategories(String userId);

  /// Kiểm tra danh mục có đang được sử dụng trong giao dịch không
  Future<Either<Failure, bool>> isCategoryInUse(String categoryId);
}