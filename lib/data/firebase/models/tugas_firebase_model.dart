// File: project_volt/data/firebase/models/tugas_firebase_model.dart (KOREKSI)

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambah impor Timestamp

class TugasFirebaseModel {
  final String? tugasId;
  final String kelasId;

  //  TAMBAHAN: Dosen ID dan Tanggal Dibuat
  final String dosenId;
  final DateTime? tglDibuat;

  final String judul;
  final String? deskripsi;

  //  KOREKSI TIPE DATA: Gunakan DateTime untuk tglTenggat
  final DateTime? tglTenggat;

  // 🎯 TAMBAHAN: ID Simulasi (Foreign Key opsional)
  final String? simulasiId;

  TugasFirebaseModel({
    this.tugasId,
    required this.kelasId,
    required this.dosenId, // Tambahan
    this.tglDibuat, // Tambahan
    required this.judul,
    this.deskripsi,
    this.tglTenggat, // Tipe DateTime
    this.simulasiId, // Tambahan
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  factory TugasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Helper untuk konversi Timestamp/String ke DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return TugasFirebaseModel(
      tugasId: id,
      kelasId: map['kelasId'] as String,
      dosenId: map['dosenId'] as String, // Ambil dosenId
      tglDibuat: parseDateTime(map['tglDibuat']), // Ambil tglDibuat
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String?,
      tglTenggat: parseDateTime(map['tglTenggat']), // Gunakan helper parse
      simulasiId: map['simulasiId'] as String?, // Ambil simulasiId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kelasId': kelasId,
      'dosenId': dosenId,
      // Konversi DateTime ke Timestamp/String
      'tglDibuat': tglDibuat != null
          ? Timestamp.fromDate(tglDibuat!)
          : FieldValue.serverTimestamp(),
      'judul': judul,
      'deskripsi': deskripsi,
      'tglTenggat': tglTenggat != null ? Timestamp.fromDate(tglTenggat!) : null,
      'simulasiId': simulasiId,
    };
  }

  // Fungsi copyWith yang sudah diperbarui
  TugasFirebaseModel copyWith({
    String? tugasId,
    String? kelasId,
    String? dosenId,
    DateTime? tglDibuat,
    String? judul,
    String? deskripsi,
    DateTime? tglTenggat,
    String? simulasiId,
  }) {
    return TugasFirebaseModel(
      tugasId: tugasId ?? this.tugasId,
      kelasId: kelasId ?? this.kelasId,
      dosenId: dosenId ?? this.dosenId,
      tglDibuat: tglDibuat ?? this.tglDibuat,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tglTenggat: tglTenggat ?? this.tglTenggat,
      simulasiId: simulasiId ?? this.simulasiId,
    );
  }

  String toJson() => json.encode(toMap());

  factory TugasFirebaseModel.fromJson(String source) =>
      TugasFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
