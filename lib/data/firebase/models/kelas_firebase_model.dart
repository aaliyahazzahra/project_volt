// File: project_volt/data/firebase/models/kelas_model_firebase.dart

import 'dart:convert';

class KelasFirebaseModel {
  // ID dokumen di Firestore (String unik)
  final String? kelasId;
  final String namaKelas;
  final String? deskripsi;
  final String kodeKelas;
  // ID Pengguna dari Firebase Auth (UID, tipe String)
  final String dosenUid;

  // 💡 FIELD BARU: Jumlah Mahasiswa Riel
  final int jumlahMahasiswa;

  KelasFirebaseModel({
    this.kelasId,
    required this.namaKelas,
    this.deskripsi,
    required this.kodeKelas,
    required this.dosenUid,
    // Tetapkan nilai default 0 agar tidak perlu ada nilai di Firestore
    this.jumlahMahasiswa = 0,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  // Konversi dari Map (dari Firestore) ke KelasFirebaseModel
  factory KelasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Kunci 'jumlahMahasiswa' diinjeksi oleh service (KelasFirebaseService)
    // jika dihitung dari koleksi lain. Jika tidak ada di map, gunakan default 0.
    final int count = map['jumlahMahasiswa'] as int? ?? 0;

    return KelasFirebaseModel(
      // Mengambil ID dari parameter jika disediakan
      kelasId: id,
      // 💡 PASTIKAN KEY INI SAMA DENGAN KEY DI toMap()
      namaKelas: map['nama_kelas'] as String,
      deskripsi: map['deskripsi'] as String?,
      kodeKelas: map['kode_kelas'] as String,
      dosenUid: map['dosenUid'] as String,

      // 💡 INISIALISASI FIELD BARU
      jumlahMahasiswa: count,
    );
  }

  // Konversi dari KelasFirebaseModel ke Map (untuk set/update di Firestore)
  // TIDAK menyertakan kelasId & jumlahMahasiswa karena yang disimpan hanya data pokok.
  Map<String, dynamic> toMap() {
    return {
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'kode_kelas': kodeKelas,
      'dosenUid': dosenUid, // Menggunakan key dosenUid (String)
      // JIKA Anda menyimpan counter di dokumen kelas, masukkan:
      // 'jumlahMahasiswa': jumlahMahasiswa,
      // Namun, saat ini kita asumsikan counter dihitung di service.
    };
  }

  // copyWith untuk mempermudah update
  KelasFirebaseModel copyWith({
    String? kelasId,
    String? namaKelas,
    String? deskripsi,
    String? kodeKelas,
    String? dosenUid,
    // 💡 FIELD BARU: Tambahkan ke copyWith
    int? jumlahMahasiswa,
  }) {
    return KelasFirebaseModel(
      kelasId: kelasId ?? this.kelasId,
      namaKelas: namaKelas ?? this.namaKelas,
      deskripsi: deskripsi ?? this.deskripsi,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      dosenUid: dosenUid ?? this.dosenUid,

      // 💡 INISIALISASI FIELD BARU
      jumlahMahasiswa: jumlahMahasiswa ?? this.jumlahMahasiswa,
    );
  }

  // Utility untuk SharedPreferences (Jika Anda perlu menyimpannya)
  String toJson() => json.encode(toMap());

  factory KelasFirebaseModel.fromJson(String source) =>
      KelasFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
