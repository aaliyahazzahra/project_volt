// project_volt/data/firebase/models/submisi_firebase_model.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmisiFirebaseModel {
  final String? submisiId;
  final String tugasId;
  final String mahasiswaId;

  //   FILE SUBMISI STANDAR
  final String? linkSubmisi;
  final String? filePathSubmisi; // Path ke file di Storage (jika ada)

  //   FIELD BARU: ID SIMULASI HASIL KERJA MAHASISWA
  final String? simulasiSubmisiId;

  //  KOREKSI TIPE DATA: Gunakan DateTime untuk submission date
  final DateTime? tglSubmit;

  //  FIELD BARU: Status Submisi (e.g., 'DISUBMIT', 'TERLAMBAT', 'DINILAI')
  final String status;

  final int? nilai; // 0-100

  SubmisiFirebaseModel({
    this.submisiId,
    required this.tugasId,
    required this.mahasiswaId,
    this.linkSubmisi,
    this.filePathSubmisi,
    this.simulasiSubmisiId, // Tambahan
    this.tglSubmit, // Tipe DateTime
    this.status = 'DRAFT', // Default Status
    this.nilai,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  factory SubmisiFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return SubmisiFirebaseModel(
      submisiId: id,
      tugasId: map['tugasId'] as String,
      mahasiswaId: map['mahasiswaId'] as String,
      linkSubmisi: map['linkSubmisi'] as String?,
      filePathSubmisi: map['filePathSubmisi'] as String?,
      simulasiSubmisiId:
          map['simulasiSubmisiId'] as String?, // Ambil ID Simulasi
      tglSubmit: parseDateTime(map['tglSubmit']), // Gunakan helper parse
      status: map['status'] as String? ?? 'DRAFT', // Ambil Status
      nilai: map['nilai'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tugasId': tugasId,
      'mahasiswaId': mahasiswaId,
      'linkSubmisi': linkSubmisi,
      'filePathSubmisi': filePathSubmisi,
      'simulasiSubmisiId': simulasiSubmisiId,
      // Simpan DateTime sebagai Timestamp untuk ketepatan waktu
      'tglSubmit': tglSubmit != null ? Timestamp.fromDate(tglSubmit!) : null,
      'status': status,
      'nilai': nilai,
    };
  }

  SubmisiFirebaseModel copyWith({
    String? submisiId,
    String? tugasId,
    String? mahasiswaId,
    String? linkSubmisi,
    String? filePathSubmisi,
    String? simulasiSubmisiId,
    DateTime? tglSubmit,
    String? status,
    int? nilai,
  }) {
    return SubmisiFirebaseModel(
      submisiId: submisiId ?? this.submisiId,
      tugasId: tugasId ?? this.tugasId,
      mahasiswaId: mahasiswaId ?? this.mahasiswaId,
      linkSubmisi: linkSubmisi ?? this.linkSubmisi,
      filePathSubmisi: filePathSubmisi ?? this.filePathSubmisi,
      simulasiSubmisiId: simulasiSubmisiId ?? this.simulasiSubmisiId,
      tglSubmit: tglSubmit ?? this.tglSubmit,
      status: status ?? this.status,
      nilai: nilai ?? this.nilai,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubmisiFirebaseModel.fromJson(String source) =>
      SubmisiFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
