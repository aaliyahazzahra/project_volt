// lib/data/firebase/service/simulasi_firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/simulasi_firebase_model.dart';
import 'package:uuid/uuid.dart'; // Import package UUID untuk ID lokal

class SimulasiFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Nama koleksi untuk menyimpan semua metadata simulasi
  final String _collection = 'simulasi';

  // Inisiasi UUID generator
  final Uuid _uuid = Uuid();

  /**
   * 1. CREATE: Menyimpan SimulasiModel baru ke Firestore.
   */
  Future<String> createSimulasi(SimulasiFirebaseModel simulasi) async {
    try {
      final String docId = _uuid.v4();
      final Map<String, dynamic> dataToSave = simulasi.toMap();

      // Tambahkan ID dokumen ke dalam data yang disimpan (optional, tapi berguna)
      dataToSave['simulasiId'] = docId;

      await _firestore.collection(_collection).doc(docId).set(dataToSave);

      return docId; // Mengembalikan ID Simulasi yang baru dibuat
    } catch (e) {
      throw Exception('Gagal membuat simulasi baru: $e');
    }
  }

  /**
   * 2. READ (LIST): Mengambil semua simulasi untuk kelas tertentu.
   */
  Future<List<SimulasiFirebaseModel>> getSimulasiByKelas(String kelasId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('kelas_id', isEqualTo: kelasId)
          .orderBy('tgl_dibuat', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SimulasiFirebaseModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      // Dalam aplikasi nyata, log error ini
      print('Error fetching simulasi by kelas: $e');
      return [];
    }
  }

  /**
   * 3. READ (DETAIL): Mengambil detail satu SimulasiModel berdasarkan ID.
   */
  Future<SimulasiFirebaseModel?> getSimulasiById(String simulasiId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(simulasiId)
          .get();

      if (docSnapshot.exists) {
        return SimulasiFirebaseModel.fromMap(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil detail simulasi: $e');
    }
  }

  /**
   * 4. UPDATE: Memperbarui metadata atau projectData simulasi.
   */
  Future<void> updateSimulasi(SimulasiFirebaseModel simulasi) async {
    if (simulasi.simulasiId == null) {
      throw Exception('Simulasi ID tidak boleh null saat update.');
    }
    try {
      await _firestore
          .collection(_collection)
          .doc(simulasi.simulasiId)
          .update(simulasi.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui simulasi: $e');
    }
  }

  /**
   * 5. DELETE: Menghapus data simulasi.
   */
  Future<void> deleteSimulasi(String simulasiId) async {
    try {
      await _firestore.collection(_collection).doc(simulasiId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus simulasi: $e');
    }
  }
}
