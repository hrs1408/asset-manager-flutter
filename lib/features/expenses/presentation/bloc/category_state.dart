import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<ExpenseCategory> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  final List<ExpenseCategory> categories;

  const CategoryOperationSuccess({
    required this.message,
    required this.categories,
  });

  @override
  List<Object> get props => [message, categories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}