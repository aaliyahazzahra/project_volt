// File: project_volt/data/firebase/models/submisi_firebase_model.dart

import 'dart:convert';

class SubmisiFirebaseModel {
  // 🔥 ID dokumen di Firestore (String unik)
  final String? submisiId;
  // 🔥 Foreign Key ke TugasModelFirebase (ID Dokumen Tugas)
  final String tugasId;
  // 🔥 Foreign Key ke UserFirebaseModel (UID Mahasiswa)
  final String mahasiswaId;

  final String? linkSubmisi;
  final String? filePathSubmisi;
  final String tglSubmit;
  final int? nilai; // 0 = belum dinilai

  SubmisiFirebaseModel({
    this.submisiId,
    required this.tugasId,
    required this.mahasiswaId,
    this.linkSubmisi,
    this.filePathSubmisi,
    required this.tglSubmit,
    this.nilai,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  // Konversi dari Map (data dari Firestore) ke SubmisiFirebaseModel
  factory SubmisiFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SubmisiFirebaseModel(
      // Mengambil ID dari parameter id dokumen
      submisiId: id,
      // Menggunakan key yang disesuaikan untuk string UID/ID Dokumen
      tugasId: map['tugasId'] as String,
      mahasiswaId: map['mahasiswaId'] as String,
      linkSubmisi: map['linkSubmisi'] as String?,
      filePathSubmisi: map['filePathSubmisi'] as String?,
      tglSubmit: map['tglSubmit'] as String,
      nilai: map['nilai'] as int?,
    );
  }

  // Konversi dari Model ke Map (untuk disimpan ke Firestore)
  // TIDAK menyertakan submisiId
  Map<String, dynamic> toMap() {
    return {
      'tugasId': tugasId,
      'mahasiswaId': mahasiswaId,
      'linkSubmisi': linkSubmisi,
      'filePathSubmisi': filePathSubmisi,
      'tglSubmit': tglSubmit,
      'nilai': nilai,
    };
  }

  // copyWith untuk mempermudah update (Opsional, tapi sangat berguna)
  SubmisiFirebaseModel copyWith({
    String? submisiId,
    String? tugasId,
    String? mahasiswaId,
    String? linkSubmisi,
    String? filePathSubmisi,
    String? tglSubmit,
    int? nilai,
  }) {
    return SubmisiFirebaseModel(
      submisiId: submisiId ?? this.submisiId,
      tugasId: tugasId ?? this.tugasId,
      mahasiswaId: mahasiswaId ?? this.mahasiswaId,
      linkSubmisi: linkSubmisi ?? this.linkSubmisi,
      filePathSubmisi: filePathSubmisi ?? this.filePathSubmisi,
      tglSubmit: tglSubmit ?? this.tglSubmit,
      nilai: nilai ?? this.nilai,
    );
  }

  // Utility untuk SharedPreferences (jika diperlukan)
  String toJson() => json.encode(toMap());

  factory SubmisiFirebaseModel.fromJson(String source) =>
      SubmisiFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
