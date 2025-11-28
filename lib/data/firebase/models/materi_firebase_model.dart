// File: project_volt/data/firebase/models/materi_firebase_model.dart

import 'dart:convert';

class MateriFirebaseModel {
  //  ID dokumen di Firestore (String unik)
  final String? materiId;
  //  Foreign Key ke KelasModelFirebase (UID/ID Dokumen Kelas)
  final String kelasId;
  final String judul;
  final String? deskripsi;
  final String? linkMateri;
  final String? filePathMateri;
  final String tglPosting; // ISO String format
  final String? simulasiId;

  MateriFirebaseModel({
    this.materiId,
    required this.kelasId,
    required this.judul,
    this.deskripsi,
    this.linkMateri,
    this.filePathMateri,
    required this.tglPosting,
    this.simulasiId,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  // Konversi dari Map (data dari Firestore) ke MateriFirebaseModel
  factory MateriFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Menggunakan operator 'as String?' untuk memastikan field yang mungkin null aman diakses.
    return MateriFirebaseModel(
      // Mengambil ID dari parameter id dokumen
      materiId: id,
      // Menggunakan key kelasId, dengan asumsi data di Firestore adalah string UID
      kelasId: map['kelasId'] as String,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String?,
      linkMateri: map['linkMateri'] as String?,
      filePathMateri: map['filePathMateri'] as String?,
      tglPosting: map['tglPosting'] as String,
      simulasiId: map['simulasiId'] as String?,
    );
  }

  // Konversi dari Model ke Map (untuk disimpan ke Firestore)
  // TIDAK menyertakan materiId (karena itu adalah Document ID)
  Map<String, dynamic> toMap() {
    return {
      'kelasId': kelasId, // Menyimpan sebagai String UID Kelas
      'judul': judul,
      'deskripsi': deskripsi,
      'linkMateri': linkMateri,
      'filePathMateri': filePathMateri,
      'tglPosting': tglPosting,
      'simulasiId': simulasiId,
    };
  }

  // copyWith untuk mempermudah update
  MateriFirebaseModel copyWith({
    String? materiId,
    String? kelasId,
    String? judul,
    String? deskripsi,
    String? linkMateri,
    String? filePathMateri,
    String? tglPosting,
    String? simulasiId,
  }) {
    return MateriFirebaseModel(
      materiId: materiId ?? this.materiId,
      kelasId: kelasId ?? this.kelasId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      linkMateri: linkMateri ?? this.linkMateri,
      filePathMateri: filePathMateri ?? this.filePathMateri,
      tglPosting: tglPosting ?? this.tglPosting,
      simulasiId: simulasiId ?? this.simulasiId,
    );
  }

  // Utility untuk SharedPreferences (jika diperlukan)
  String toJson() => json.encode(toMap());

  factory MateriFirebaseModel.fromJson(String source) =>
      MateriFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
