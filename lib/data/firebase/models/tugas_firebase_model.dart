// File: project_volt/data/firebase/models/tugas_firebase_model.dart

import 'dart:convert';

class TugasFirebaseModel {
  // 🔥 ID dokumen di Firestore (String unik)
  final String? tugasId;
  // 🔥 Foreign Key ke KelasModelFirebase (ID Dokumen Kelas)
  final String kelasId;
  final String judul;
  final String? deskripsi;
  final String? tglTenggat; // ISO String format

  TugasFirebaseModel({
    this.tugasId,
    required this.kelasId,
    required this.judul,
    this.deskripsi,
    this.tglTenggat,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  // Konversi dari Map (data dari Firestore) ke TugasFirebaseModel
  factory TugasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TugasFirebaseModel(
      // Mengambil ID dari parameter id dokumen
      tugasId: id,
      // Menggunakan key kelasId, dengan asumsi data di Firestore adalah string ID
      kelasId: map['kelasId'] as String,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String?,
      tglTenggat: map['tglTenggat'] as String?,
    );
  }

  // Konversi dari Model ke Map (untuk disimpan ke Firestore)
  // TIDAK menyertakan tugasId
  Map<String, dynamic> toMap() {
    return {
      'kelasId': kelasId, // Menyimpan sebagai String ID Kelas
      'judul': judul,
      'deskripsi': deskripsi,
      'tglTenggat': tglTenggat,
    };
  }

  // Fungsi copyWith untuk mempermudah update
  TugasFirebaseModel copyWith({
    String? tugasId,
    String? kelasId,
    String? judul,
    String? deskripsi,
    String? tglTenggat,
  }) {
    return TugasFirebaseModel(
      tugasId: tugasId ?? this.tugasId,
      kelasId: kelasId ?? this.kelasId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tglTenggat: tglTenggat ?? this.tglTenggat,
    );
  }

  // Utility untuk SharedPreferences (jika diperlukan)
  String toJson() => json.encode(toMap());

  factory TugasFirebaseModel.fromJson(String source) =>
      TugasFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
