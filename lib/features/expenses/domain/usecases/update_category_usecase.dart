import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase implements UseCase<ExpenseCategory, UpdateCategoryParams> {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, ExpenseCategory>> call(UpdateCategoryParams params) async {
    final updatedCategory = params.category.copyWith(
      name: params.name,
      description: params.description,
      icon: params.icon,
      updatedAt: DateTime.now(),
    );

    return await repository.updateCategory(updatedCategory);
  }
}

class UpdateCategoryParams {
  final ExpenseCategory category;
  final String name;
  final String description;
  final String icon;

  UpdateCategoryParams({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
  });
}