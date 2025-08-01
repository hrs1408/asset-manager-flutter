import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String userId;

  const LoadCategories(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateCategory extends CategoryEvent {
  final String userId;
  final String name;
  final String description;
  final String icon;

  const CreateCategory({
    required this.userId,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  List<Object> get props => [userId, name, description, icon];
}

class UpdateCategory extends CategoryEvent {
  final ExpenseCategory category;
  final String name;
  final String description;
  final String icon;

  const UpdateCategory({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  List<Object> get props => [category, name, description, icon];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class InitializeDefaultCategories extends CategoryEvent {
  final String userId;

  const InitializeDefaultCategories(this.userId);

  @override
  List<Object> get props => [userId];
}