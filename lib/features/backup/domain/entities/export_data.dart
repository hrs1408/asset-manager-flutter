import 'dart:convert';
import '../../../assets/domain/entities/asset.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/domain/entities/transaction.dart';

class ExportData {
  final String userId;
  final String userEmail;
  final DateTime exportDate;
  final List<Asset> assets;
  final List<ExpenseCategory> categories;
  final List<Transaction> transactions;

  ExportData({
    required this.userId,
    required this.userEmail,
    required this.exportDate,
    required this.assets,
    required this.categories,
    required this.transactions,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'exportDate': exportDate.toIso8601String(),
      'exportVersion': '1.0',
      'data': {
        'assets': assets.map((asset) => {
          'id': asset.id,
          'name': asset.name,
          'type': asset.type.name,
          'balance': asset.balance,
          'createdAt': asset.createdAt.toIso8601String(),
          'updatedAt': asset.updatedAt.toIso8601String(),
        }).toList(),
        'categories': categories.map((category) => {
          'id': category.id,
          'name': category.name,
          'description': category.description,
          'icon': category.icon,
          'isDefault': category.isDefault,
        }).toList(),
        'transactions': transactions.map((transaction) => {
          'id': transaction.id,
          'assetId': transaction.assetId,
          'categoryId': transaction.categoryId,
          'amount': transaction.amount,
          'description': transaction.description,
          'date': transaction.date.toIso8601String(),
          'createdAt': transaction.createdAt.toIso8601String(),
        }).toList(),
      },
      'summary': {
        'totalAssets': assets.length,
        'totalCategories': categories.length,
        'totalTransactions': transactions.length,
        'totalAssetValue': assets.fold<double>(0, (sum, asset) => sum + asset.balance),
        'totalExpenses': transactions.fold<double>(0, (sum, transaction) => sum + transaction.amount),
      },
    };
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      userId: json['userId'],
      userEmail: json['userEmail'],
      exportDate: DateTime.parse(json['exportDate']),
      assets: [], // Would need proper deserialization
      categories: [], // Would need proper deserialization
      transactions: [], // Would need proper deserialization
    );
  }
}