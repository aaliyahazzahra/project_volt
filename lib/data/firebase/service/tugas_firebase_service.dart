// File: project_volt/data/firebase/service/tugas_firebase_service.dart (Koreksi Real-Time)

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';

// Definisi Custom Exception
class TugasServiceException implements Exception {
  final String message;
  TugasServiceException(this.message);
  @override
  String toString() => 'TugasServiceException: $message';
}

class TugasFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksi utama untuk Tugas
  static const String _collectionName = 'tugas';

  // ----------------------------------------------------
  // 1. CREATE: Membuat Tugas Baru
  // ----------------------------------------------------
  /// Menyimpan objek TugasFirebaseModel baru ke Firestore.
  Future<TugasFirebaseModel> createTugas(TugasFirebaseModel tugas) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(tugas.toMap());

      // Mengembalikan model lengkap dengan ID dokumen
      return tugas.copyWith(tugasId: docRef.id);
    } catch (e) {
      log('Error creating task: $e', error: e);
      throw TugasServiceException('Gagal membuat tugas di Firestore.');
    }
  }

  // ----------------------------------------------------
  // 2. READ: Mengambil Daftar Tugas (STREAM - REAL-TIME) 💡 BARU: Kunci Solusi
  // ----------------------------------------------------
  /// Mengambil semua tugas untuk Kelas tertentu secara REAL-TIME.
  Stream<List<TugasFirebaseModel>> getTugasStreamByKelas(String kelasId) {
    // Kunci: Menggunakan .snapshots() untuk Stream<QuerySnapshot>
    return _firestore
        .collection(_collectionName)
        .where('kelasId', isEqualTo: kelasId)
        .orderBy('tglTenggat', descending: true)
        .snapshots() // 🔑 Perubahan Penting di sini
        .map((snapshot) {
          // Mapping dari QuerySnapshot ke List<TugasFirebaseModel>
          return snapshot.docs.map((doc) {
            // Mapping data dan menyertakan ID dokumen
            final data = doc.data();
            return TugasFirebaseModel.fromMap(data, id: doc.id);
          }).toList();
        });
  }

  // ----------------------------------------------------
  // 2.1. READ: Mengambil Daftar Tugas (FUTURE - ONE-TIME FETCH)
  // ----------------------------------------------------
  /// Mengambil semua tugas untuk Kelas tertentu (hanya sekali).
  /// Fungsi ini dipertahankan, namun disarankan menggunakan fungsi Stream di atas
  /// untuk tampilan daftar tugas.
  Future<List<TugasFirebaseModel>> getTugasFutureByKelas(String kelasId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('kelasId', isEqualTo: kelasId)
          .orderBy('tglTenggat', descending: true)
          .get(); // ❗ Tetap menggunakan .get() jika hanya butuh sekali ambil

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TugasFirebaseModel.fromMap(data, id: doc.id);
      }).toList();
    } catch (e) {
      log('Error getting tasks by class: $e', error: e);
      throw TugasServiceException('Gagal memuat daftar tugas.');
    }
  }

  // ----------------------------------------------------
  // 3. READ: Mengambil Tugas Berdasarkan ID
  // ----------------------------------------------------
  /// Mengambil data spesifik untuk satu tugas saja.
  Future<TugasFirebaseModel?> getTugasById(String tugasId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(tugasId)
          .get();

      if (!doc.exists) {
        return null;
      }
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return TugasFirebaseModel.fromMap(data, id: doc.id);
    } on FirebaseException catch (e) {
      log('Firestore Error getting task by ID: ${e.code}', error: e);
      throw TugasServiceException(
        'Terjadi kesalahan saat memuat detail tugas.',
      );
    } catch (e) {
      log('Error getting task by ID: $e', error: e);
      throw TugasServiceException('Gagal memuat data tugas.');
    }
  }

  // ----------------------------------------------------
  // 4. UPDATE: Memperbarui Tugas
  // ----------------------------------------------------
  /// Memperbarui data tugas berdasarkan tugasId.
  Future<void> updateTugas(TugasFirebaseModel tugas) async {
    if (tugas.tugasId == null) {
      throw TugasServiceException("Tugas ID tidak ditemukan untuk pembaruan.");
    }
    try {
      await _firestore
          .collection(_collectionName)
          .doc(tugas.tugasId)
          .update(tugas.toMap());
    } catch (e) {
      log('Error updating task: $e', error: e);
      throw TugasServiceException('Gagal memperbarui tugas.');
    }
  }

  // ----------------------------------------------------
  // 5. DELETE: Menghapus Tugas
  // ----------------------------------------------------
  /// Menghapus tugas berdasarkan tugasId.
  Future<void> deleteTugas(String tugasId) async {
    try {
      await _firestore.collection(_collectionName).doc(tugasId).delete();
    } catch (e) {
      log('Error deleting task: $e', error: e);
      throw TugasServiceException('Gagal menghapus tugas.');
    }
  }
}
