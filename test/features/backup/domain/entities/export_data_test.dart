import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_tai_san/features/backup/domain/entities/export_data.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/expense_category.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/transaction.dart';

void main() {
  group('ExportData', () {
    test('should convert to JSON correctly', () {
      // Arrange
      final exportData = ExportData(
        userId: 'test-user',
        userEmail: 'test@example.com',
        exportDate: DateTime(2024, 1, 1, 12, 0, 0),
        assets: [
          Asset(
            id: 'asset-1',
            userId: 'test-user',
            name: 'Test Asset',
            type: AssetType.paymentAccount,
            balance: 1000.0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        categories: [
          ExpenseCategory(
            id: 'category-1',
            userId: 'test-user',
            name: 'Test Category',
            description: 'Test Description',
            icon: 'test_icon',
            isDefault: false,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        transactions: [
          Transaction(
            id: 'transaction-1',
            userId: 'test-user',
            assetId: 'asset-1',
            categoryId: 'category-1',
            amount: 100.0,
            description: 'Test Transaction',
            date: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
      );

      // Act
      final json = exportData.toJson();

      // Assert
      expect(json['userId'], 'test-user');
      expect(json['userEmail'], 'test@example.com');
      expect(json['exportVersion'], '1.0');
      expect(json['data']['assets'], hasLength(1));
      expect(json['data']['categories'], hasLength(1));
      expect(json['data']['transactions'], hasLength(1));
      expect(json['summary']['totalAssets'], 1);
      expect(json['summary']['totalCategories'], 1);
      expect(json['summary']['totalTransactions'], 1);
      expect(json['summary']['totalAssetValue'], 1000.0);
      expect(json['summary']['totalExpenses'], 100.0);
    });

    test('should convert to JSON string correctly', () {
      // Arrange
      final exportData = ExportData(
        userId: 'test-user',
        userEmail: 'test@example.com',
        exportDate: DateTime(2024, 1, 1),
        assets: [],
        categories: [],
        transactions: [],
      );

      // Act
      final jsonString = exportData.toJsonString();

      // Assert
      expect(jsonString, isA<String>());
      expect(jsonString.contains('"userId": "test-user"'), true);
      expect(jsonString.contains('"userEmail": "test@example.com"'), true);
      expect(jsonString.contains('"exportVersion": "1.0"'), true);
    });

    test('should calculate summary correctly', () {
      // Arrange
      final exportData = ExportData(
        userId: 'test-user',
        userEmail: 'test@example.com',
        exportDate: DateTime(2024, 1, 1),
        assets: [
          Asset(
            id: 'asset-1',
            userId: 'test-user',
            name: 'Asset 1',
            type: AssetType.paymentAccount,
            balance: 1000.0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          Asset(
            id: 'asset-2',
            userId: 'test-user',
            name: 'Asset 2',
            type: AssetType.savingsAccount,
            balance: 2000.0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        categories: [
          ExpenseCategory(
            id: 'category-1',
            userId: 'test-user',
            name: 'Category 1',
            description: 'Description 1',
            icon: 'icon1',
            isDefault: false,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        transactions: [
          Transaction(
            id: 'transaction-1',
            userId: 'test-user',
            assetId: 'asset-1',
            categoryId: 'category-1',
            amount: 100.0,
            description: 'Transaction 1',
            date: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          Transaction(
            id: 'transaction-2',
            userId: 'test-user',
            assetId: 'asset-2',
            categoryId: 'category-1',
            amount: 200.0,
            description: 'Transaction 2',
            date: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
        ],
      );

      // Act
      final json = exportData.toJson();
      final summary = json['summary'];

      // Assert
      expect(summary['totalAssets'], 2);
      expect(summary['totalCategories'], 1);
      expect(summary['totalTransactions'], 2);
      expect(summary['totalAssetValue'], 3000.0);
      expect(summary['totalExpenses'], 300.0);
    });

    test('should handle empty data correctly', () {
      // Arrange
      final exportData = ExportData(
        userId: 'test-user',
        userEmail: 'test@example.com',
        exportDate: DateTime(2024, 1, 1),
        assets: [],
        categories: [],
        transactions: [],
      );

      // Act
      final json = exportData.toJson();
      final summary = json['summary'];

      // Assert
      expect(summary['totalAssets'], 0);
      expect(summary['totalCategories'], 0);
      expect(summary['totalTransactions'], 0);
      expect(summary['totalAssetValue'], 0.0);
      expect(summary['totalExpenses'], 0.0);
    });
  });
}