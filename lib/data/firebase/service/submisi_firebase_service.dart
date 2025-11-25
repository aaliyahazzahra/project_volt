// File: project_volt/data/firebase/service/submisi_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
// Asumsi: SubmisiDetailFirebase didefinisikan di sini atau diimpor

// --- Helper Class (seperti di atas) ---
class SubmisiDetailFirebase {
  final SubmisiFirebaseModel submisi;
  final UserFirebaseModel mahasiswa;

  SubmisiDetailFirebase({required this.submisi, required this.mahasiswa});
}
// ----------------------------------------

class SubmisiFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'submisi';
  static const String _userCollection =
      'users'; // Dari FirebaseService sebelumnya

  // ----------------------------------------------------
  // 1. CREATE/UPDATE: Mengumpulkan atau Memperbarui Submisi
  // ----------------------------------------------------
  /// Menggunakan Compound Key (tugasId + mahasiswaId) untuk cek dan update.
  Future<void> createOrUpdateSubmisi(SubmisiFirebaseModel submisi) async {
    // Firestore tidak memiliki 'conflictAlgorithm.replace' seperti Sqflite.
    // Kita membuat ID unik gabungan untuk menjamin hanya ada SATU submisi per tugas per mhs.
    final String uniqueId = '${submisi.tugasId}_${submisi.mahasiswaId}';

    // Perhatikan: Kita menggunakan set() dengan uniqueId. Jika dokumen sudah ada, akan ditimpa.
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uniqueId)
          .set(submisi.toMap());
    } catch (e) {
      log('Error creating/updating submission: $e');
      throw Exception('Gagal menyimpan atau memperbarui submisi tugas.');
    }
  }

  // ----------------------------------------------------
  // 2. READ: Mengecek Submisi Mahasiswa
  // ----------------------------------------------------
  /// Mengecek submisi Mahasiswa sebelumnya untuk Tugas tertentu.
  Future<SubmisiFirebaseModel?> getSubmisiByTugasAndMahasiswa(
    String tugasId,
    String mahasiswaId,
  ) async {
    try {
      final String uniqueId = '${tugasId}_$mahasiswaId';
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(uniqueId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return SubmisiFirebaseModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id, // ID dokumen adalah uniqueId gabungan
      );
    } catch (e) {
      log('Error getting submission: $e');
      throw Exception('Gagal memuat status submisi.');
    }
  }

  // ----------------------------------------------------
  // 3. READ: Melihat Semua Submisi (Daftar Dasar)
  // ----------------------------------------------------
  /// Melihat semua submisi untuk satu tugas (tanpa detail user).
  Future<List<SubmisiFirebaseModel>> getAllSubmisiByTugas(
    String tugasId,
  ) async {
    try {
      // Menggunakan query where. Perlu index Firestore untuk field 'tugasId'
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('tugasId', isEqualTo: tugasId)
          .orderBy('tglSubmit', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return SubmisiFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      log('Error getting all submissions: $e');
      throw Exception('Gagal memuat daftar submisi tugas.');
    }
  }

  // ----------------------------------------------------
  // 4. READ (Relasional): Melihat Detail Submisi (untuk Dosen)
  // ----------------------------------------------------
  /// Mengambil data Submisi dan detail Mahasiswa yang melakukan submisi (Simulasi JOIN).
  Future<List<SubmisiDetailFirebase>> getSubmisiDetailByTugas(
    String tugasId,
  ) async {
    // NOTE: Firestore tidak memiliki JOIN. Kita melakukan 'client-side join'
    // dengan memuat Submisi, lalu memuat data User terkait satu per satu (atau secara batch).
    try {
      // 1. Ambil semua Submisi untuk tugas ini
      final submisiSnapshot = await _firestore
          .collection(_collectionName)
          .where('tugasId', isEqualTo: tugasId)
          .get();

      if (submisiSnapshot.docs.isEmpty) {
        return [];
      }

      // 2. Kumpulkan semua Mahasiswa ID (UID) yang terlibat
      // final List<String> mhsUids = submisiSnapshot.docs
      //     .map((doc) => (doc.data())['mahasiswaId'] as String)
      //     .toList();

      // 3. Ambil data profil Mahasiswa secara batch (jika jumlah UID banyak, ini lebih efisien)
      // Sayangnya, Firestore limit query IN adalah 10, jadi kita lakukan iterasi/batch.
      final List<SubmisiDetailFirebase> resultList = [];

      for (var doc in submisiSnapshot.docs) {
        final submisiData = SubmisiFirebaseModel.fromMap(
          doc.data(),
          id: doc.id,
        );

        // Ambil detail user satu per satu
        final userDoc = await _firestore
            .collection(_userCollection)
            .doc(submisiData.mahasiswaId)
            .get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData = userDoc.data()!;

          // 🔥 1. Pastikan UID dari Document ID ditambahkan ke map
          userData['uid'] = userDoc.id;

          // Opsional: Pastikan email diambil dari data jika tidak dijamin ada
          // userData['email'] = userData['email'] ?? '';

          // 2. Panggil fromMap dengan map yang sudah lengkap
          final userModel = UserFirebaseModel.fromMap(userData);

          resultList.add(
            SubmisiDetailFirebase(submisi: submisiData, mahasiswa: userModel),
          );
        }
      }

      return resultList;
    } catch (e) {
      log('Error performing relational query for submission details: $e');
      throw Exception('Gagal memuat detail submisi (relational query).');
    }
  }

  // ----------------------------------------------------
  // 5. DELETE: Menghapus Submisi
  // ----------------------------------------------------
  /// Menghapus submisi berdasarkan ID gabungan.
  Future<void> deleteSubmisiByTugasAndMahasiswa(
    String tugasId,
    String mahasiswaId,
  ) async {
    try {
      final String uniqueId = '${tugasId}_$mahasiswaId';
      await _firestore.collection(_collectionName).doc(uniqueId).delete();
    } catch (e) {
      log('Error deleting submission: $e');
      throw Exception('Gagal menghapus submisi.');
    }
  }
}
