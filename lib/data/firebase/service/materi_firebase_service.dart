// File: project_volt/data/firebase/service/materi_firebase_service.dart

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';

class MateriFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksi utama untuk Materi
  static const String _collectionName = 'materi';

  // ----------------------------------------------------
  // 1. CREATE: Membuat Materi Baru
  // ----------------------------------------------------
  /// Menyimpan objek MateriFirebaseModel baru ke Firestore.
  Future<MateriFirebaseModel> createMateri(MateriFirebaseModel materi) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(materi.toMap());

      // Mengembalikan model lengkap dengan ID dokumen
      return materi.copyWith(materiId: docRef.id);
    } catch (e) {
      log('Error creating material: $e');
      throw Exception('Gagal membuat materi di Firestore.');
    }
  }

  // ----------------------------------------------------
  // 2. READ: Mengambil Daftar Materi (STREAM - REAL-TIME) 💡 Perubahan Utama
  // ----------------------------------------------------
  /// Mengambil semua materi untuk Kelas tertentu secara REAL-TIME.
  Stream<List<MateriFirebaseModel>> getMateriStreamByKelas(String kelasId) {
    // Query yang sama, tetapi menggunakan .snapshots()
    return _firestore
        .collection(_collectionName)
        .where('kelasId', isEqualTo: kelasId)
        .orderBy('tglPosting', descending: true)
        .snapshots() // Kunci: Mengembalikan Stream<QuerySnapshot>
        .map((snapshot) {
          // Mapping dari QuerySnapshot ke List<MateriFirebaseModel>
          return snapshot.docs.map((doc) {
            return MateriFirebaseModel.fromMap(
              doc.data(),
              id: doc.id, // Menyediakan ID dokumen sebagai materiId
            );
          }).toList();
        });
  }

  // ----------------------------------------------------
  // 2.1. READ: Mengambil Daftar Materi (FUTURE - ONE-TIME FETCH)
  // ----------------------------------------------------
  /// Mengambil semua materi untuk Kelas tertentu (hanya sekali).
  Future<List<MateriFirebaseModel>> getMateriByKelas(String kelasId) async {
    try {
      // Query berdasarkan kelasId (Foreign Key)
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('kelasId', isEqualTo: kelasId)
          .orderBy(
            'tglPosting',
            descending: true,
          ) // Tampilkan yang terbaru di atas
          .get(); // Kunci: Menggunakan .get() untuk Future

      // Mapping data dari snapshot Firestore
      return snapshot.docs.map((doc) {
        return MateriFirebaseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id, // Menyediakan ID dokumen sebagai materiId
        );
      }).toList();
    } catch (e) {
      log('Error getting materials by class: $e');
      throw Exception('Gagal memuat daftar materi.');
    }
  }

  // ----------------------------------------------------
  // 2.5. READ: Mengambil Materi Tunggal Berdasarkan ID
  // ----------------------------------------------------
  /// Mengambil satu Materi berdasarkan materiId.
  Future<MateriFirebaseModel?> getMateriById(String materiId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(materiId)
          .get();

      if (docSnapshot.exists) {
        return MateriFirebaseModel.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
          id: docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      log('Error getting material by ID: $e');
      throw Exception('Gagal memuat detail materi.');
    }
  }

  // ----------------------------------------------------
  // 3. UPDATE: Memperbarui Materi
  // ----------------------------------------------------
  /// Memperbarui data materi berdasarkan materiId.
  Future<void> updateMateri(MateriFirebaseModel materi) async {
    if (materi.materiId == null) {
      throw Exception("Materi ID tidak ditemukan untuk pembaruan.");
    }
    try {
      await _firestore
          .collection(_collectionName)
          .doc(materi.materiId)
          .update(materi.toMap());
    } catch (e) {
      log('Error updating material: $e');
      throw Exception('Gagal memperbarui materi.');
    }
  }

  // ----------------------------------------------------
  // 4. DELETE: Menghapus Materi
  // ----------------------------------------------------
  /// Menghapus materi berdasarkan materiId.
  Future<void> deleteMateri(String materiId) async {
    try {
      await _firestore.collection(_collectionName).doc(materiId).delete();
    } catch (e) {
      log('Error deleting material: $e');
      throw Exception('Gagal menghapus materi.');
    }
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String kelasId) async {
    // Membuat path unik di Firebase Storage
    final fileName = p.basename(file.path);
    final ref = _storage.ref().child(
      'materi/$kelasId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );

    // Upload file
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});

    // Dapatkan URL publik
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl; // Ini yang disimpan di Firestore
  }
}
