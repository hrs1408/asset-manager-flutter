import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Đăng nhập thất bại');
      }

      return await _getUserFromFirestore(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Lỗi không xác định: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Đăng ký thất bại');
      }

      // Create user document in Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: null,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .collection('profile')
          .doc('info')
          .set(userModel.toJson());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      throw AuthException(_mapFirestoreError(e.code));
    } catch (e) {
      throw AuthException('Lỗi không xác định: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Lỗi đăng xuất: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Lỗi đặt lại mật khẩu: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      throw AuthException('Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();

      if (!doc.exists) {
        // Create user document if it doesn't exist
        final now = DateTime.now();
        final firebaseUser = _firebaseAuth.currentUser!;
        final userModel = UserModel(
          id: uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          createdAt: now,
          updatedAt: now,
        );

        await doc.reference.set(userModel.toJson());
        return userModel;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw AuthException('Lỗi lấy thông tin người dùng từ Firestore: ${e.toString()}');
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này không được cho phép';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Lỗi xác thực: $code';
    }
  }

  String _mapFirestoreError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Không có quyền truy cập. Vui lòng kiểm tra cấu hình Firestore Security Rules';
      case 'not-found':
        return 'Không tìm thấy dữ liệu';
      case 'already-exists':
        return 'Dữ liệu đã tồn tại';
      case 'resource-exhausted':
        return 'Đã vượt quá giới hạn sử dụng';
      case 'failed-precondition':
        return 'Điều kiện tiên quyết không được đáp ứng';
      case 'aborted':
        return 'Thao tác bị hủy bỏ';
      case 'out-of-range':
        return 'Giá trị nằm ngoài phạm vi cho phép';
      case 'unimplemented':
        return 'Chức năng chưa được triển khai';
      case 'internal':
        return 'Lỗi nội bộ của server';
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng';
      case 'data-loss':
        return 'Mất dữ liệu không thể khôi phục';
      case 'unauthenticated':
        return 'Chưa xác thực. Vui lòng đăng nhập lại';
      default:
        return 'Lỗi Firestore: $code';
    }
  }
}