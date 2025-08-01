import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CreateCategoryUseCase createCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final InitializeDefaultCategoriesUseCase initializeDefaultCategoriesUseCase;

  CategoryBloc({
    required this.createCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.initializeDefaultCategoriesUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<InitializeDefaultCategories>(_onInitializeDefaultCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final result = await getCategoriesUseCase(event.userId);
    
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final params = CreateCategoryParams(
      userId: event.userId,
      name: event.name,
      description: event.description,
      icon: event.icon,
    );
    
    final result = await createCategoryUseCase(params);
    
    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (category) async {
        // Reload categories after successful creation
        final categoriesResult = await getCategoriesUseCase(event.userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryOperationSuccess(
            message: 'Tạo danh mục thành công',
            categories: categories,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final params = UpdateCategoryParams(
      category: event.category,
      name: event.name,
      description: event.description,
      icon: event.icon,
    );
    
    final result = await updateCategoryUseCase(params);
    
    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (category) async {
        // Reload categories after successful update
        final categoriesResult = await getCategoriesUseCase(event.category.userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryOperationSuccess(
            message: 'Cập nhật danh mục thành công',
            categories: categories,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final params = DeleteCategoryParams(categoryId: event.categoryId);
    final result = await deleteCategoryUseCase(params);
    
    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (_) async {
        // Get current state to determine userId for reload
        if (state is CategoryLoaded) {
          final currentState = state as CategoryLoaded;
          if (currentState.categories.isNotEmpty) {
            final userId = currentState.categories.first.userId;
            final categoriesResult = await getCategoriesUseCase(userId);
            categoriesResult.fold(
              (failure) => emit(CategoryError(failure.message)),
              (categories) => emit(CategoryOperationSuccess(
                message: 'Xóa danh mục thành công',
                categories: categories,
              )),
            );
          }
        }
      },
    );
  }

  Future<void> _onInitializeDefaultCategories(
    InitializeDefaultCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    final result = await initializeDefaultCategoriesUseCase(event.userId);
    
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryOperationSuccess(
        message: 'Khởi tạo danh mục mặc định thành công',
        categories: categories,
      )),
    );
  }
}