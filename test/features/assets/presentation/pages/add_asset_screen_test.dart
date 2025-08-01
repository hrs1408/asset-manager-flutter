import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/bloc/asset_bloc.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/bloc/asset_event.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/bloc/asset_state.dart';
import 'package:quan_ly_tai_san/features/assets/presentation/pages/add_asset_screen.dart';
import '../../../../helpers/test_helper.dart';

class MockAssetBloc extends Mock implements AssetBloc {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  late MockAssetBloc mockAssetBloc;

  setUp(() {
    mockAssetBloc = MockAssetBloc();
    when(() => mockAssetBloc.state).thenReturn(const AssetInitial());
    when(() => mockAssetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AssetBloc>(
        create: (context) => mockAssetBloc,
        child: const AddAssetScreen(userId: 'test-user-id'),
      ),
    );
  }

  group('AddAssetScreen Widget Tests', () {
    testWidgets('should display all required UI elements', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Thêm tài sản mới'), findsNWidgets(2)); // AppBar and body
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('Nhập thông tin tài sản của bạn'), findsOneWidget);
      expect(find.text('Tên tài sản'), findsOneWidget);
      expect(find.text('Loại tài sản'), findsOneWidget);
      expect(find.text('Số dư hiện tại'), findsOneWidget);
      expect(find.text('Đơn vị: VNĐ'), findsOneWidget);
      expect(find.text('Thêm tài sản'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Thêm tài sản'));
      await tester.pump();

      // assert
      expect(find.text('Vui lòng nhập tên tài sản'), findsOneWidget);
      expect(find.text('Vui lòng nhập số dư'), findsOneWidget);
    });

    testWidgets('should show validation error for short asset name', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Thêm tài sản'));
      await tester.pump();

      // assert
      expect(find.text('Tên tài sản phải có ít nhất 2 ký tự'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid balance', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'Test Asset');
      await tester.enterText(find.byType(TextFormField).last, 'invalid');
      await tester.tap(find.text('Thêm tài sản'));
      await tester.pump();

      // assert
      expect(find.text('Số dư không hợp lệ'), findsOneWidget);
    });

    testWidgets('should show validation error for negative balance', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'Test Asset');
      await tester.enterText(find.byType(TextFormField).last, '-100');
      await tester.tap(find.text('Thêm tài sản'));
      await tester.pump();

      // assert
      expect(find.text('Số dư không thể âm'), findsOneWidget);
    });

    testWidgets('should format currency input correctly', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).last, '1000000');
      await tester.pump();

      // assert - should format with commas
      final textField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      expect(textField.controller?.text, '1,000,000');
    });

    testWidgets('should change asset type when dropdown is selected', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - tap on dropdown to open it
      await tester.tap(find.byType(DropdownButtonFormField<AssetType>));
      await tester.pumpAndSettle();

      // Select savings account
      await tester.tap(find.text('Tài khoản tiết kiệm').last);
      await tester.pumpAndSettle();

      // assert - dropdown should show selected value
      expect(find.text('Tài khoản tiết kiệm'), findsOneWidget);
    });

    testWidgets('should dispatch AssetCreateRequested when form is valid', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'Test Asset');
      await tester.enterText(find.byType(TextFormField).last, '1000000');
      await tester.tap(find.text('Thêm tài sản'));
      await tester.pump();

      // assert
      verify(() => mockAssetBloc.add(any(that: isA<AssetCreateRequested>()))).called(1);
    });

    testWidgets('should show loading state when AssetOperationLoading', (tester) async {
      // arrange
      when(() => mockAssetBloc.state).thenReturn(const AssetOperationLoading());
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when AssetError', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - simulate AssetError state
      when(() => mockAssetBloc.state).thenReturn(const AssetError(message: 'Failed to create asset'));
      mockAssetBloc.emit(const AssetError(message: 'Failed to create asset'));
      await tester.pump();

      // assert
      expect(find.text('Failed to create asset'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show success snackbar and navigate back when AssetOperationSuccess', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - simulate AssetOperationSuccess state
      when(() => mockAssetBloc.state).thenReturn(const AssetOperationSuccess(message: 'Asset created successfully'));
      mockAssetBloc.emit(const AssetOperationSuccess(message: 'Asset created successfully'));
      await tester.pump();

      // assert
      expect(find.text('Asset created successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should navigate back when cancel button is tapped', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      // assert - should navigate back (screen should be popped)
      expect(find.text('Thêm tài sản mới'), findsNothing);
    });
  });
}