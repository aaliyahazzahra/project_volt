// File: project_volt/data/firebase/service/kelas_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';

class KelasFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi di Firestore
  static const String _collectionName = 'kelas';

  // ----------------------------------------------------
  // 1. CREATE: Membuat Kelas Baru
  // ----------------------------------------------------
  /// Menyimpan objek KelasModelFirebase baru ke Firestore.
  Future<KelasFirebaseModel> createKelas(KelasFirebaseModel kelas) async {
    try {
      // 1. Dapatkan referensi koleksi
      final collectionRef = _firestore.collection(_collectionName);

      // 2. Tambahkan data kelas
      final docRef = await collectionRef.add(kelas.toMap());

      // 3. Ambil ID yang dibuat Firestore dan kembalikan model lengkap
      return kelas.copyWith(kelasId: docRef.id);
    } catch (e) {
      log('Error creating class: $e');
      throw Exception('Gagal membuat kelas di Firestore.');
    }
  }

  // ----------------------------------------------------
  // 2. READ: Mengambil Kelas Berdasarkan Dosen UID
  // ----------------------------------------------------
  /// Mengambil semua kelas yang dibuat oleh Dosen tertentu.
  Future<List<KelasFirebaseModel>> getKelasByDosen(String dosenUid) async {
    try {
      // Query berdasarkan dosenUid (harus sama dengan key di toMap)
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('dosenUid', isEqualTo: dosenUid)
          // .orderBy('nama_kelas', descending: false) // Urutkan A-Z
          .get();

      // Mapping data dari snapshot Firestore ke List<KelasModelFirebase>
      return snapshot.docs.map((doc) {
        // Menggunakan factory fromMap dan menyediakan doc.id sebagai kelasId
        return KelasFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      log('Error getting classes by Dosen: $e');
      throw Exception('Gagal memuat daftar kelas.');
    }
  }

  // ----------------------------------------------------
  // 3. UPDATE: Memperbarui Data Kelas
  // ----------------------------------------------------
  /// Memperbarui data kelas berdasarkan kelasId.
  Future<void> updateKelas(KelasFirebaseModel kelas) async {
    if (kelas.kelasId == null) {
      throw Exception("Kelas ID tidak ditemukan untuk pembaruan.");
    }
    try {
      // Menggunakan update() untuk memodifikasi field yang ada
      await _firestore
          .collection(_collectionName)
          .doc(kelas.kelasId)
          .update(kelas.toMap());
    } catch (e) {
      log('Error updating class: $e');
      throw Exception('Gagal memperbarui kelas.');
    }
  }

  // ----------------------------------------------------
  // 4. DELETE: Menghapus Kelas
  // ----------------------------------------------------
  /// Menghapus kelas berdasarkan kelasId.
  Future<void> deleteKelas(String kelasId) async {
    try {
      await _firestore.collection(_collectionName).doc(kelasId).delete();

      // CATATAN PENTING: Untuk Firestore, Anda harus secara manual
      // menghapus Sub-koleksi (seperti 'anggota_kelas', 'tugas', 'materi')
      // yang terikat pada kelasId ini, karena Firestore tidak memiliki ON DELETE CASCADE.
      // Implementasi ini memerlukan pembersihan data yang lebih lanjut.
    } catch (e) {
      log('Error deleting class: $e');
      throw Exception('Gagal menghapus kelas.');
    }
  }

  // Tambahkan fungsi ini ke KelasFirebaseService Anda:

  Future<KelasFirebaseModel?> getKelasById(String kelasId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(kelasId)
          .get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return KelasFirebaseModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      log('Error getting class by ID: $e');
      throw Exception('Gagal memuat data kelas.');
    }
  }
}
