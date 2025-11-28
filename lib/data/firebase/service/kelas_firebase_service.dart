// File: project_volt/data/firebase/service/kelas_firebase_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart'; // Pastikan model sudah diperbarui

class KelasFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi di Firestore
  static const String _collectionName = 'kelas';
  static const String _enrollmentsCollection =
      'enrollments'; // Nama koleksi Mahasiswa/Enrollments

  // ----------------------------------------------------
  // FUNGSI UTILITY: MENGHITUNG JUMLAH ANGGOTA KELAS
  // ----------------------------------------------------

  /// Menghitung jumlah dokumen di koleksi 'enrollments' yang merujuk ke kelasId ini.
  Future<int> _hitungJumlahMahasiswa(String kelasId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_enrollmentsCollection)
          // Asumsi setiap dokumen enrollment memiliki field 'kelasId'
          .where('kelasId', isEqualTo: kelasId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      log('Error counting students for class $kelasId: $e');
      // Kembalikan 0 jika terjadi error agar aplikasi tidak crash
      return 0;
    }
  }

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
  // 2. READ: Mengambil Kelas Berdasarkan Dosen UID (DENGAN JUMLAH MAHASISWA)
  // ----------------------------------------------------

  /// Mengambil semua kelas yang dibuat oleh Dosen tertentu, termasuk jumlah mahasiswa riil.
  Future<List<KelasFirebaseModel>> getKelasByDosen(String dosenUid) async {
    try {
      // 1. Query berdasarkan dosenUid
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('dosenUid', isEqualTo: dosenUid)
          .get();

      // 2. Mapping data dari snapshot Firestore ke List<KelasModelFirebase>
      final List<KelasFirebaseModel> daftarKelas = [];

      for (var doc in snapshot.docs) {
        final kelasId = doc.id;
        final data = doc.data() as Map<String, dynamic>;

        // 3. Panggil fungsi utility untuk MENGHITUNG JUMLAH MAHASISWA RIIL
        final jumlahMahasiswa = await _hitungJumlahMahasiswa(kelasId);

        // 4. Buat model dengan data riil jumlah mahasiswa
        final kelasModel = KelasFirebaseModel.fromMap({
          ...data,
          // Injeksi jumlahMahasiswa yang sudah dihitung ke dalam data map
          'jumlahMahasiswa': jumlahMahasiswa,
        }, id: kelasId);
        daftarKelas.add(kelasModel);
      }

      return daftarKelas;
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

      // CATATAN PENTING: Anda mungkin perlu menambahkan
      // logika untuk menghapus data terkait di koleksi lain
      // (misalnya, semua dokumen di 'enrollments' yang memiliki kelasId ini).
      // Contoh: await _deleteRelatedEnrollments(kelasId);
    } catch (e) {
      log('Error deleting class: $e');
      throw Exception('Gagal menghapus kelas.');
    }
  }

  // ----------------------------------------------------
  // 5. READ: Mengambil Kelas Berdasarkan ID
  // ----------------------------------------------------

  /// Mengambil data kelas tunggal berdasarkan kelasId.
  Future<KelasFirebaseModel?> getKelasById(String kelasId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(kelasId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;

      // Opsi: Hitung juga jumlah mahasiswa jika Anda mengambil kelas tunggal
      final jumlahMahasiswa = await _hitungJumlahMahasiswa(kelasId);

      return KelasFirebaseModel.fromMap({
        ...data,
        'jumlahMahasiswa': jumlahMahasiswa,
      }, id: doc.id);
    } catch (e) {
      log('Error getting class by ID: $e');
      throw Exception('Gagal memuat data kelas.');
    }
  }
}
