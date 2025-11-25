import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../data/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đăng nhập
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _db
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("Login Error: ${e.toString()}");
      return null;
    }
    return null;
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String className,
  }) async {
    try {
      // 1. Tạo tài khoản trên Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // 2. Tạo model dữ liệu
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          role: role,
          name: name,
          className: className,
        );

        // 3. Lưu thông tin phụ (Tên, Lớp, Vai trò) vào Firestore
        await _db
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toMap());

        return newUser;
      }
    } catch (e) {
      print("Register Error: ${e.toString()}");
      return null;
    }
    return null;
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Lấy user hiện tại (nếu app khởi động lại)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}