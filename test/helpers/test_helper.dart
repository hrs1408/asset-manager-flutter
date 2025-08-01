import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/usecases/usecase.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/expense_category.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/transaction.dart';

class FakeAsset extends Fake implements Asset {}
class FakeExpenseCategory extends Fake implements ExpenseCategory {}
class FakeTransaction extends Fake implements Transaction {}
class FakeNoParams extends Fake implements NoParams {}
class FakeSignInParams extends Fake implements SignInParams {}
class FakeSignUpParams extends Fake implements SignUpParams {}
class FakeResetPasswordParams extends Fake implements ResetPasswordParams {}

void registerFallbackValues() {
  registerFallbackValue(FakeAsset());
  registerFallbackValue(FakeExpenseCategory());
  registerFallbackValue(FakeTransaction());
  registerFallbackValue(FakeNoParams());
  registerFallbackValue(FakeSignInParams());
  registerFallbackValue(FakeSignUpParams());
  registerFallbackValue(FakeResetPasswordParams());
}

// Test data helpers
class TestData {
  static final DateTime testDateTime = DateTime(2024, 1, 1);
  
  static Asset createTestAsset({
    String id = 'test-asset-id',
    String userId = 'test-user-id',
    String name = 'Test Asset',
    AssetType type = AssetType.paymentAccount,
    double balance = 1000000,
  }) {
    return Asset(
      id: id,
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );
  }

  static ExpenseCategory createTestCategory({
    String id = 'test-category-id',
    String userId = 'test-user-id',
    String name = 'Test Category',
    String description = 'Test Description',
    String icon = '🏷️',
    bool isDefault = false,
  }) {
    return ExpenseCategory(
      id: id,
      userId: userId,
      name: name,
      description: description,
      icon: icon,
      isDefault: isDefault,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );
  }

  static Transaction createTestTransaction({
    String id = 'test-transaction-id',
    String userId = 'test-user-id',
    String assetId = 'test-asset-id',
    String categoryId = 'test-category-id',
    double amount = 100000,
    String description = 'Test Transaction',
  }) {
    return Transaction(
      id: id,
      userId: userId,
      assetId: assetId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: testDateTime,
      createdAt: testDateTime,
    );
  }
}