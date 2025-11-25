// File: project_volt/data/firebase/service/tugas_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';

class TugasFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksi utama untuk Tugas
  static const String _collectionName = 'tugas';

  // ----------------------------------------------------
  // 1. CREATE: Membuat Tugas Baru
  // ----------------------------------------------------
  /// Menyimpan objek TugasModelFirebase baru ke Firestore.
  Future<TugasFirebaseModel> createTugas(TugasFirebaseModel tugas) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(tugas.toMap());

      return tugas.copyWith(tugasId: docRef.id);
    } catch (e) {
      log('Error creating task: $e');
      throw Exception('Gagal membuat tugas di Firestore.');
    }
  }

  // ----------------------------------------------------
  // 2. READ: Mengambil Daftar Tugas Berdasarkan Kelas ID
  // ----------------------------------------------------
  /// Mengambil semua tugas untuk Kelas tertentu.
  Future<List<TugasFirebaseModel>> getTugasByKelas(String kelasId) async {
    try {
      // Query berdasarkan kelasId (Foreign Key)
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('kelasId', isEqualTo: kelasId)
          .orderBy(
            'tglTenggat',
            descending: true,
          ) // Tampilkan yang terbaru di atas
          .get();

      // Mapping data dari snapshot Firestore
      return snapshot.docs.map((doc) {
        return TugasFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id, // Menyediakan ID dokumen sebagai tugasId
        );
      }).toList();
    } catch (e) {
      log('Error getting tasks by class: $e');
      throw Exception('Gagal memuat daftar tugas.');
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

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return TugasFirebaseModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    } catch (e) {
      log('Error getting task by ID: $e');
      throw Exception('Gagal memuat data tugas.');
    }
  }

  // ----------------------------------------------------
  // 4. UPDATE: Memperbarui Tugas
  // ----------------------------------------------------
  /// Memperbarui data tugas berdasarkan tugasId.
  Future<void> updateTugas(TugasFirebaseModel tugas) async {
    if (tugas.tugasId == null) {
      throw Exception("Tugas ID tidak ditemukan untuk pembaruan.");
    }
    try {
      await _firestore
          .collection(_collectionName)
          .doc(tugas.tugasId)
          .update(tugas.toMap());
    } catch (e) {
      log('Error updating task: $e');
      throw Exception('Gagal memperbarui tugas.');
    }
  }

  // ----------------------------------------------------
  // 5. DELETE: Menghapus Tugas
  // ----------------------------------------------------
  /// Menghapus tugas berdasarkan tugasId.
  Future<void> deleteTugas(String tugasId) async {
    try {
      await _firestore.collection(_collectionName).doc(tugasId).delete();

      // CATATAN PENTING: Untuk Firestore, Anda harus menghapus Sub-koleksi
      // atau dokumen terkait (misalnya, submisi yang terkait dengan tugasId ini)
      // secara manual.
    } catch (e) {
      log('Error deleting task: $e');
      throw Exception('Gagal menghapus tugas.');
    }
  }
}
