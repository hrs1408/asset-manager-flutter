import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/bloc/asset_bloc.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/bloc/asset_state.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_state.dart';
import 'package:quan_ly_tai_san/features/auth/domain/entities/user.dart';
import 'package:quan_ly_tai_san/features/expenses/presentation/bloc/category_bloc.dart';
import 'package:quan_ly_tai_san/features/expenses/presentation/bloc/category_state.dart';
import 'package:quan_ly_tai_san/features/expenses/presentation/bloc/transaction_bloc.dart';
import 'package:quan_ly_tai_san/features/expenses/presentation/bloc/transaction_state.dart';
import 'package:quan_ly_tai_san/features/expenses/presentation/pages/add_transaction_screen.dart';
import '../../../../helpers/test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockAssetBloc extends Mock implements AssetBloc {}
class MockCategoryBloc extends Mock implements CategoryBloc {}
class MockTransactionBloc extends Mock implements TransactionBloc {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  late MockAuthBloc mockAuthBloc;
  late MockAssetBloc mockAssetBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockTransactionBloc mockTransactionBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockAssetBloc = MockAssetBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockTransactionBloc = MockTransactionBloc();

    final testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user: testUser));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAssetBloc.state).thenReturn(const AssetInitial());
    when(() => mockAssetBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryBloc.state).thenReturn(const CategoryInitial());
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTransactionBloc.state).thenReturn(const TransactionInitial());
    when(() => mockTransactionBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => mockAuthBloc),
          BlocProvider<AssetBloc>(create: (context) => mockAssetBloc),
          BlocProvider<CategoryBloc>(create: (context) => mockCategoryBloc),
          BlocProvider<TransactionBloc>(create: (context) => mockTransactionBloc),
        ],
        child: const AddTransactionScreen(),
      ),
    );
  }

  group('AddTransactionScreen Widget Tests', () {
    testWidgets('should display all required UI elements', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Thêm giao dịch'), findsOneWidget);
      expect(find.text('Số tiền'), findsOneWidget);
      expect(find.text('Mô tả'), findsOneWidget);
      expect(find.text('Chọn tài sản'), findsOneWidget);
      expect(find.text('Chọn danh mục'), findsOneWidget);
      expect(find.text('Ngày giao dịch'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty required fields', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - try to submit without filling required fields
      await tester.tap(find.text('Thêm giao dịch'));
      await tester.pump();

      // assert
      expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
      expect(find.text('Vui lòng nhập mô tả'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid amount', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.tap(find.text('Thêm giao dịch'));
      await tester.pump();

      // assert
      expect(find.text('Số tiền không hợp lệ'), findsOneWidget);
    });

    testWidgets('should show validation error for zero amount', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.tap(find.text('Thêm giao dịch'));
      await tester.pump();

      // assert
      expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    });

    testWidgets('should format currency input correctly', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, '1000000');
      await tester.pump();

      // assert - should format with commas
      final textField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(textField.controller?.text, contains(','));
    });

    testWidgets('should show date picker when date field is tapped', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should show loading state when TransactionLoading', (tester) async {
      // arrange
      when(() => mockTransactionBloc.state).thenReturn(const TransactionLoading());
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when TransactionError', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - simulate TransactionError state
      when(() => mockTransactionBloc.state).thenReturn(const TransactionError(message: 'Failed to create transaction'));
      mockTransactionBloc.emit(const TransactionError(message: 'Failed to create transaction'));
      await tester.pump();

      // assert
      expect(find.text('Failed to create transaction'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should navigate back when cancel button is tapped', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      // assert - should navigate back (screen should be popped)
      expect(find.text('Thêm giao dịch'), findsNothing);
    });
  });
}