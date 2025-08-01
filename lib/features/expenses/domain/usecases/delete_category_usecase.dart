import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    // Check if category is in use before deleting
    final isInUseResult = await repository.isCategoryInUse(params.categoryId);
    
    return isInUseResult.fold(
      (failure) => Left(failure),
      (isInUse) async {
        if (isInUse) {
          return Left(ValidationFailure('Không thể xóa danh mục đang được sử dụng trong giao dịch'));
        }
        return await repository.deleteCategory(params.categoryId);
      },
    );
  }
}

class DeleteCategoryParams {
  final String categoryId;

  DeleteCategoryParams({required this.categoryId});
}