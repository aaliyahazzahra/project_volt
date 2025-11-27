// File: project_volt/data/firebase/service/firebase.dart

import 'dart:developer'; // Tambahkan ini untuk logging

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class FirebaseService {
  // Instance statis untuk kemudahan akses
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String userCollection = 'users';

  /// Registrasi pengguna baru di Firebase Auth dan menyimpan data di Firestore.
  static Future<UserFirebaseModel> registerUser({
    required String email,
    required String namaLengkap,
    required String password,
    required String role,
    required String nimNidn,
    required String namaKampus,
  }) async {
    try {
      // 1. Firebase Authentication: Membuat user baru
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;

      // 2. Membuat Model Sesi Awal (dengan data profil dasar)
      final model = UserFirebaseModel(
        uid: user.uid,
        token: null, // Token belum perlu diambil di sini
        email: email,
        namaLengkap: namaLengkap,
        role: role,
        // Properti yang masih null (akan diisi di langkah berikutnya, misal NIM/Kampus)
        nimNidn: null,
        namaKampus: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // 3. Firestore: Menyimpan data profil dasar ke collection 'users'
      // Menggunakan uid sebagai Document ID
      await firestore
          .collection(userCollection)
          .doc(user.uid)
          .set(model.toMap());

      return model;
    } on FirebaseAuthException {
      rethrow; // Biarkan UI/Business Logic menangani error spesifik Auth (misal: email-already-in-use)
    } catch (e) {
      log('Error registering user: $e');
      throw Exception('Gagal melakukan pendaftaran. Periksa koneksi Anda.');
    }
  }

  /// 🔑 Login pengguna menggunakan Firebase Auth dan mengambil data profil dari Firestore.
  static Future<UserFirebaseModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Firebase Authentication: Sign In
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;

      if (user == null) return null; // Harusnya tidak terjadi

      // 2. Ambil ID Token (Bearer Token)
      final idToken = await user.getIdToken();

      // 3. Firestore: Ambil data profil
      final snap = await firestore
          .collection(userCollection)
          .doc(user.uid)
          .get();

      if (!snap.exists || snap.data() == null) {
        // Jika Auth berhasil, tapi data di Firestore hilang
        await auth.signOut(); // Logout dari Auth
        throw Exception('Data profil tidak ditemukan. Sesi dibatalkan.');
      }

      final userData = snap.data()!;

      // 4. Gabungkan data Auth dan Firestore ke Model
      return UserFirebaseModel.fromMap({
        'uid': user.uid,
        'token': idToken, // Tambahkan token sesi ke model
        'email': user.email, // Pastikan email ada
        ...userData, // Timpa dengan data dari Firestore (namaLengkap, role, dll.)
      });
    } on FirebaseAuthException catch (e) {
      // Handle error kredensial (Invalid-credential, user-not-found, wrong-password)
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return null; // Mengembalikan null agar UI menampilkan "Email atau password salah"
      }

      // Log error lain (Network, too-many-requests, dll.)
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow; // Lempar ulang exception untuk ditangani di UI (misal: error koneksi)
    } catch (e) {
      log('Error logging in: $e');
      throw Exception('Gagal terhubung ke server. Periksa koneksi Anda.');
    }
  }

  /// 🚪 Logout pengguna dari Firebase Auth
  static Future<void> logoutUser() async {
    try {
      await auth.signOut();
    } catch (e) {
      log('Error logging out: $e');
      throw Exception('Gagal logout. Silakan coba lagi.');
    }
  }
}
