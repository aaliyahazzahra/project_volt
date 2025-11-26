// File: project_volt/data/firebase/models/kelas_model_firebase.dart

import 'dart:convert';

class KelasFirebaseModel {
  //  ID dokumen di Firestore (String unik)
  final String? kelasId;
  final String namaKelas;
  final String? deskripsi;
  final String kodeKelas;
  //  ID Pengguna dari Firebase Auth (UID, tipe String)
  final String dosenUid;

  KelasFirebaseModel({
    this.kelasId,
    required this.namaKelas,
    this.deskripsi,
    required this.kodeKelas,
    required this.dosenUid,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  // Konversi dari Map (dari Firestore) ke KelasFirebaseModel
  // Catatan: Firestore tidak menyimpan 'kelasId' di dalam dokumen, tetapi sebagai ID dokumen itu sendiri.
  // Oleh karena itu, kita harus memasukkan 'kelasId' secara manual saat memanggil fromMap.
  factory KelasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return KelasFirebaseModel(
      // Mengambil ID dari parameter jika disediakan
      kelasId: id,
      namaKelas: map['nama_kelas'] as String,
      deskripsi: map['deskripsi'] as String?,
      kodeKelas: map['kode_kelas'] as String,
      // Menggunakan key dosenUid
      dosenUid: map['dosenUid'] as String,
    );
  }

  // Konversi dari KelasFirebaseModel ke Map (untuk set/update di Firestore)
  // TIDAK menyertakan kelasId karena itu adalah Document ID.
  Map<String, dynamic> toMap() {
    return {
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'kode_kelas': kodeKelas,
      'dosenUid': dosenUid, // Menggunakan key dosenUid (String)
    };
  }

  // copyWith untuk mempermudah update
  KelasFirebaseModel copyWith({
    String? kelasId,
    String? namaKelas,
    String? deskripsi,
    String? kodeKelas,
    String? dosenUid,
  }) {
    return KelasFirebaseModel(
      kelasId: kelasId ?? this.kelasId,
      namaKelas: namaKelas ?? this.namaKelas,
      deskripsi: deskripsi ?? this.deskripsi,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      dosenUid: dosenUid ?? this.dosenUid,
    );
  }

  // Utility untuk SharedPreferences (Jika Anda perlu menyimpannya)
  String toJson() => json.encode(toMap());

  factory KelasFirebaseModel.fromJson(String source) =>
      KelasFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
