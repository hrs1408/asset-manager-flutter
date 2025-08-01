import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense_category.dart';
import '../repositories/category_repository.dart';

class InitializeDefaultCategoriesUseCase implements UseCase<List<ExpenseCategory>, String> {
  final CategoryRepository repository;

  InitializeDefaultCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExpenseCategory>>> call(String userId) async {
    return await repository.initializeDefaultCategories(userId);
  }
}