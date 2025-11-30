// File: project_volt/data/firebase/service/submisi_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
// Asumsi: SubmisiDetailFirebase didefinisikan di sini atau diimpor

// --- Helper Class (Model Join Data untuk Dosen) ---
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
  // (Otomatis menangani textSubmisi karena menggunakan submisi.toMap())
  // ----------------------------------------------------
  /// Menggunakan Compound Key (tugasId + mahasiswaId) untuk cek dan update.
  Future<void> createOrUpdateSubmisi(SubmisiFirebaseModel submisi) async {
    // ID yang akan digunakan adalah submisiId, atau ID gabungan jika submisiId null
    final String uniqueId =
        submisi.submisiId ?? '${submisi.tugasId}_${submisi.mahasiswaId}';

    try {
      // NOTE: submisi.toMap() kini sudah menyertakan field textSubmisi
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
  // (Otomatis menangani textSubmisi karena menggunakan SubmisiFirebaseModel.fromMap())
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

      // NOTE: SubmisiFirebaseModel.fromMap() kini bisa membaca field textSubmisi
      return SubmisiFirebaseModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id, // ID dokumen adalah uniqueId gabungan
      );
    } catch (e) {
      log('Error getting submission: $e');
      return null;
    }
  }

  // ----------------------------------------------------
  // 3. READ: Melihat Semua Submisi (Daftar Dasar)
  // (Otomatis menangani textSubmisi karena menggunakan SubmisiFirebaseModel.fromMap())
  // ----------------------------------------------------
  /// Melihat semua submisi untuk satu tugas (tanpa detail user).
  Future<List<SubmisiFirebaseModel>> getAllSubmisiByTugas(
    String tugasId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('tugasId', isEqualTo: tugasId)
          .orderBy('tglSubmit', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        // NOTE: SubmisiFirebaseModel.fromMap() kini bisa membaca field textSubmisi
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
  // (Otomatis menangani textSubmisi karena menggunakan SubmisiFirebaseModel.fromMap())
  // ----------------------------------------------------
  /// Mengambil data Submisi dan detail Mahasiswa yang melakukan submisi (Simulasi JOIN).
  Future<List<SubmisiDetailFirebase>> getSubmisiDetailByTugas(
    String tugasId,
  ) async {
    try {
      // 1. Ambil semua Submisi untuk tugas ini
      final submisiSnapshot = await _firestore
          .collection(_collectionName)
          .where('tugasId', isEqualTo: tugasId)
          .get();

      if (submisiSnapshot.docs.isEmpty) {
        return [];
      }

      final List<SubmisiDetailFirebase> resultList = [];

      for (var doc in submisiSnapshot.docs) {
        final Map<String, dynamic> docData = doc.data();

        // NOTE: SubmisiFirebaseModel.fromMap() kini bisa membaca field textSubmisi
        final submisiData = SubmisiFirebaseModel.fromMap(docData, id: doc.id);

        // 2. Ambil detail user satu per satu (client-side join)
        final userDoc = await _firestore
            .collection(_userCollection)
            .doc(submisiData.mahasiswaId)
            .get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData = userDoc.data()!;

          // Tambahkan UID dari Document ID agar model dapat menginisiasi UID
          userData['uid'] = userDoc.id;

          // 3. Panggil UserFirebaseModel.fromMap yang sudah lengkap
          final userModel = UserFirebaseModel.fromMap(userData);

          resultList.add(
            SubmisiDetailFirebase(submisi: submisiData, mahasiswa: userModel),
          );
        } else {
          // Jika data user hilang, tetap tambahkan submisi dengan user model default
          resultList.add(
            SubmisiDetailFirebase(
              submisi: submisiData,
              mahasiswa: UserFirebaseModel(
                uid: submisiData.mahasiswaId,
                role: 'mhs',
                namaLengkap: 'User Tidak Ditemukan',
                email:
                    'mahasiswa_${submisiData.mahasiswaId.substring(0, 5)}@volt.app',
              ),
            ),
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
  // 5. UPDATE: Menilai Submisi
  // ----------------------------------------------------
  /// Mengupdate nilai dan status penilaian (digunakan oleh Dosen).
  Future<void> updateNilai({
    required String submisiId,
    required int nilai,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(submisiId).update({
        'nilai': nilai,
        // Setelah dinilai, status diubah menjadi 'DINILAI'
        'status': 'DINILAI',
      });
    } catch (e) {
      log("Error updating submission score: $e");
      rethrow;
    }
  }

  // ----------------------------------------------------
  // 6. DELETE: Menghapus Submisi
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
