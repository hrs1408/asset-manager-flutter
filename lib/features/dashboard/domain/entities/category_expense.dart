import 'package:equatable/equatable.dart';
import '../../../expenses/domain/entities/expense_category.dart';

class CategoryExpense extends Equatable {
  final ExpenseCategory category;
  final double totalAmount;
  final int transactionCount;
  final double percentage;

  const CategoryExpense({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        category,
        totalAmount,
        transactionCount,
        percentage,
      ];
}