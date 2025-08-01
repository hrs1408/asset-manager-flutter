import '../models/user_model.dart';

abstract class AuthService {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Reset password for given email
  Future<void> resetPassword({required String email});

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}