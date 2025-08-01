import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_card.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/edit_category_dialog.dart';
import '../../domain/entities/expense_category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(LoadCategories(authState.user.id));
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showEditCategoryDialog(ExpenseCategory category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }

  void _deleteCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa danh mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CategoryBloc>().add(DeleteCategory(categoryId));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _initializeDefaultCategories() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(InitializeDefaultCategories(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh mục'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'init_default') {
                _initializeDefaultCategories();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'init_default',
                child: Text('Khởi tạo danh mục mặc định'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ExpenseCategory> categories = [];
          if (state is CategoryLoaded) {
            categories = state.categories;
          } else if (state is CategoryOperationSuccess) {
            categories = state.categories;
          }

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có danh mục nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeDefaultCategories,
                    child: const Text('Khởi tạo danh mục mặc định'),
                  ),
                ],
              ),
            );
          }

          // Separate default and custom categories
          final defaultCategories = categories.where((c) => c.isDefault).toList();
          final customCategories = categories.where((c) => !c.isDefault).toList();

          return RefreshIndicator(
            onRefresh: () async => _loadCategories(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (defaultCategories.isNotEmpty) ...[
                  const Text(
                    'Danh mục mặc định',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...defaultCategories.map((category) => CategoryCard(
                    category: category,
                    onEdit: () => _showEditCategoryDialog(category),
                    onDelete: null, // Cannot delete default categories
                  )),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Danh mục tùy chỉnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (customCategories.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có danh mục tùy chỉnh nào',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...customCategories.map((category) => CategoryCard(
                    category: category,
                    onEdit: () => _showEditCategoryDialog(category),
                    onDelete: () => _deleteCategory(category.id),
                  )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}