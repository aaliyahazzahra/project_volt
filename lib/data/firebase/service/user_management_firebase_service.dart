// File: project_volt/data/firebase/service/user_management_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class UserManagementFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _userCollection = 'users';
  static const String _kelasCollection = 'kelas';
  static const String _anggotaCollection =
      'kelas_anggota'; // Koleksi relasi M-to-M

  // ----------------------------------------------------
  // 1. UPDATE: Melengkapi Profil (NIM/NIDN & Kampus)
  // ----------------------------------------------------
  /// Memperbarui field nimNidn dan namaKampus di dokumen user yang sudah ada.
  Future<void> updateProfileDetails({
    required String uid,
    required String nimNidn,
    required String namaKampus,
  }) async {
    try {
      await _firestore.collection(_userCollection).doc(uid).update({
        'nimNidn': nimNidn,
        'namaKampus': namaKampus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('Error updating profile details: $e');
      throw Exception('Gagal memperbarui data profil.');
    }
  }

  // ----------------------------------------------------
  // 2. KEANGGOTAAN: Mahasiswa Bergabung dengan Kelas (joinKelas)
  // ----------------------------------------------------
  /// Mencari kelas berdasarkan kode dan memasukkan relasi keanggotaan.
  Future<String> joinKelas(String mahasiswaUid, String kodeKelas) async {
    try {
      // 1. Cari Kelas berdasarkan kodeKelas
      final kelasSnapshot = await _firestore
          .collection(_kelasCollection)
          .where('kode_kelas', isEqualTo: kodeKelas)
          .limit(1)
          .get();

      if (kelasSnapshot.docs.isEmpty) {
        return "Error: Kode Kelas tidak ditemukan.";
      }

      final String kelasId = kelasSnapshot.docs.first.id;
      final String uniqueAnggotaId = '${kelasId}_$mahasiswaUid';

      // 2. Cek apakah Mahasiswa sudah terdaftar (UNIQUE constraint Sqflite digantikan oleh Document ID)
      final anggotaDoc = await _firestore
          .collection(_anggotaCollection)
          .doc(uniqueAnggotaId)
          .get();

      if (anggotaDoc.exists) {
        return "Error:   sudah terdaftar di kelas ini.";
      }

      // 3. Masukkan relasi keanggotaan
      await _firestore.collection(_anggotaCollection).doc(uniqueAnggotaId).set({
        'kelasId': kelasId,
        'mahasiswaUid': mahasiswaUid,
        'joinedAt': DateTime.now().toIso8601String(),
      });

      return "Sukses: Berhasil bergabung dengan kelas!";
    } catch (e) {
      log('Error joining class: $e');
      throw Exception('Gagal bergabung dengan kelas.');
    }
  }

  // ----------------------------------------------------
  // 3. KEANGGOTAAN: Mahasiswa Keluar dari Kelas (leaveKelas)
  // ----------------------------------------------------
  Future<void> leaveKelas(String mahasiswaUid, String kelasId) async {
    try {
      final String uniqueAnggotaId = '${kelasId}_$mahasiswaUid';
      await _firestore
          .collection(_anggotaCollection)
          .doc(uniqueAnggotaId)
          .delete();
    } catch (e) {
      log('Error leaving class: $e');
      throw Exception('Gagal keluar dari kelas.');
    }
  }

  // ----------------------------------------------------
  // 4. READ: Mendapatkan Semua Kelas yang Diikuti Mahasiswa
  // ----------------------------------------------------
  Future<List<KelasFirebaseModel>> getKelasByMahasiswa(
    String mahasiswaUid,
  ) async {
    try {
      // 1. Ambil semua relasi keanggotaan Mahasiswa ini
      final anggotaSnapshot = await _firestore
          .collection(_anggotaCollection)
          .where('mahasiswaUid', isEqualTo: mahasiswaUid)
          .get();

      if (anggotaSnapshot.docs.isEmpty) {
        return [];
      }

      // 2. Kumpulkan semua ID Kelas
      final List<String> kelasIds = anggotaSnapshot.docs
          .map((doc) => (doc.data())['kelasId'] as String)
          .toList();

      // 3. Ambil data Kelas (menggunakan query IN, batasan 10 di Firestore)
      // Perlu membagi array kelasIds menjadi batch jika jumlahnya > 10
      if (kelasIds.isEmpty) return [];

      final kelasSnapshot = await _firestore
          .collection(_kelasCollection)
          .where(FieldPath.documentId, whereIn: kelasIds)
          .get();

      // 4. Mapping ke KelasModelFirebase
      return kelasSnapshot.docs.map((doc) {
        return KelasFirebaseModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    } catch (e) {
      log('Error getting classes by student: $e');
      throw Exception('Gagal memuat daftar kelas yang diikuti.');
    }
  }

  // ----------------------------------------------------
  // 5. READ: Mendapatkan Anggota (Mahasiswa) di Kelas Tertentu
  // ----------------------------------------------------
  Future<List<UserFirebaseModel>> getAnggotaByKelas(String kelasId) async {
    try {
      // 1. Ambil semua relasi keanggotaan untuk Kelas ini
      final anggotaSnapshot = await _firestore
          .collection(_anggotaCollection)
          .where('kelasId', isEqualTo: kelasId)
          .get();

      if (anggotaSnapshot.docs.isEmpty) {
        return [];
      }

      // 2. Kumpulkan semua Mahasiswa UID
      final List<String> mhsUids = anggotaSnapshot.docs
          .map((doc) => (doc.data())['mahasiswaUid'] as String)
          .toList();

      // 3. Ambil data profil Mahasiswa (menggunakan query IN, batasan 10 di Firestore)
      if (mhsUids.isEmpty) return [];

      final userSnapshot = await _firestore
          .collection(_userCollection)
          .where(FieldPath.documentId, whereIn: mhsUids)
          .get();

      // 4. Mapping ke UserFirebaseModel
      return userSnapshot.docs.map((doc) {
        final userData = doc.data();
        // Tambahkan UID dari Document ID karena tidak selalu ada di Map data
        userData['uid'] = doc.id;
        return UserFirebaseModel.fromMap(userData);
      }).toList();
    } catch (e) {
      log('Error getting class members: $e');
      throw Exception('Gagal memuat daftar anggota kelas.');
    }
  }
}
