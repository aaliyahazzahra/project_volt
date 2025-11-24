import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<UserFirebaseModel> registerUser({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final model = UserFirebaseModel(
      uid: user.uid,
      email: email,
      username: username,
      role: role,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await firestore.collection('users').doc(user.uid).set(model.toMap());
    return model;
  }

  static Future<UserFirebaseModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;
      final snap = await firestore.collection('users').doc(user.uid).get();
      if (!snap.exists) return null;
      return UserFirebaseModel.fromMap({'uid': user.uid, ...snap.data()!});
    } on FirebaseAuthException catch (e) {
      // handle credential error → return null, biar UI bisa "Email/password salah"
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return null;
      }

      // kalau error lain (network, too-many-requests, dll) boleh kamu log
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow; // biar ketauan saat debug
    }
  }
}
