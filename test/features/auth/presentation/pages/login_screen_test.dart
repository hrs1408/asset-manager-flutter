import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_event.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_state.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/pages/login_screen.dart';
import '../../../../helpers/test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (context) => mockAuthBloc,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display all required UI elements', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('Quản lý Tài sản'), findsOneWidget);
      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? '), findsOneWidget);
      expect(find.text('Đăng ký ngay'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // assert
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // assert
      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('should show validation error for short password', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // assert
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - find the password visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pump();

      // assert - icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('should dispatch AuthSignInRequested when form is valid', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      // assert
      verify(() => mockAuthBloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      ))).called(1);
    });

    testWidgets('should show loading state when AuthLoading', (tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when AuthError', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act - simulate AuthError state
      when(() => mockAuthBloc.state).thenReturn(const AuthError(message: 'Login failed'));
      mockAuthBloc.emit(const AuthError(message: 'Login failed'));
      await tester.pump();

      // assert
      expect(find.text('Login failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should navigate to register screen when sign up link is tapped', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Đăng ký ngay'));
      await tester.pumpAndSettle();

      // assert - should navigate to register screen
      expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen when forgot password is tapped', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // act
      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();

      // assert - should navigate to forgot password screen
      expect(find.text('Đặt lại mật khẩu'), findsOneWidget);
    });
  });
}