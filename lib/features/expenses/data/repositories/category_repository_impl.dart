import 'package:dartz/dartz.dart';


import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/expense_category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirestoreService _firestoreService;

  CategoryRepositoryImpl({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<Either<Failure, ExpenseCategory>> createCategory(
    ExpenseCategory category,
  ) async {
    try {
      final categoryModel = ExpenseCategoryModel.fromEntity(category);
      final docId = await _firestoreService.createDocument(
        AppConstants.categoriesCollection,
        categoryModel.toFirestore(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.categoriesCollection,
        docId,
      );

      final createdCategory = ExpenseCategoryModel.fromFirestore(doc);
      return Right(createdCategory.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseCategory>>> getCategories(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        AppConstants.categoriesCollection,
      );

      final categories = querySnapshot.docs
          .map((doc) => ExpenseCategoryModel.fromFirestore(doc).toEntity())
          .toList();

      // Sắp xếp: default categories trước, sau đó theo tên
      categories.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });

      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final doc = await _firestoreService.getDocument(
        AppConstants.categoriesCollection,
        categoryId,
      );

      if (!doc.exists) {
        return const Left(NotFoundFailure('Category not found'));
      }

      final category = ExpenseCategoryModel.fromFirestore(doc);
      return Right(category.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> updateCategory(
    ExpenseCategory category,
  ) async {
    try {
      // Không cho phép cập nhật default categories
      if (category.isDefault) {
        return const Left(ValidationFailure(
          'Không thể chỉnh sửa danh mục mặc định'
        ));
      }

      final categoryModel = ExpenseCategoryModel.fromEntity(category);
      await _firestoreService.updateDocument(
        AppConstants.categoriesCollection,
        category.id,
        categoryModel.toFirestoreUpdate(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.categoriesCollection,
        category.id,
      );

      final updatedCategory = ExpenseCategoryModel.fromFirestore(doc);
      return Right(updatedCategory.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      // Kiểm tra xem có phải default category không
      final categoryResult = await getCategoryById(categoryId);
      if (categoryResult.isLeft()) {
        return categoryResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      final category = categoryResult.getOrElse(() => throw Exception());
      if (category.isDefault) {
        return const Left(ValidationFailure(
          'Không thể xóa danh mục mặc định'
        ));
      }

      // Kiểm tra xem category có đang được sử dụng trong transaction không
      final isInUse = await isCategoryInUse(categoryId);
      if (isInUse.isRight() && isInUse.getOrElse(() => false)) {
        return const Left(ValidationFailure(
          'Không thể xóa danh mục đang được sử dụng trong giao dịch'
        ));
      }

      await _firestoreService.deleteDocument(
        AppConstants.categoriesCollection,
        categoryId,
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
  Future<Either<Failure, List<ExpenseCategory>>> initializeDefaultCategories(
    String userId,
  ) async {
    try {
      // Kiểm tra xem đã có default categories chưa
      final existingCategories = await getCategories(userId);
      if (existingCategories.isRight()) {
        final categories = existingCategories.getOrElse(() => []);
        final hasDefaultCategories = categories.any((cat) => cat.isDefault);
        
        if (hasDefaultCategories) {
          // Đã có default categories, trả về danh sách hiện tại
          return existingCategories;
        }
      }

      // Tạo default categories
      final defaultCategories = ExpenseCategory.getDefaultCategories(userId);
      final List<ExpenseCategory> createdCategories = [];

      for (final category in defaultCategories) {
        final categoryModel = ExpenseCategoryModel.fromEntity(category);
        
        // Sử dụng ID cố định cho default categories
        await _firestoreService.getUserCollection(AppConstants.categoriesCollection)
            .doc(category.id)
            .set(categoryModel.toFirestore());

        createdCategories.add(category);
      }

      return Right(createdCategories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCategoryInUse(String categoryId) async {
    try {
      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        field: 'categoryId',
        isEqualTo: categoryId,
        limit: 1,
      );

      return Right(querySnapshot.docs.isNotEmpty);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}