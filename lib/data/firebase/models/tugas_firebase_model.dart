import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TugasFirebaseModel {
  final String? tugasId;
  final String kelasId;

  final String dosenId;
  final DateTime? tglDibuat;

  final String judul;
  final String? deskripsi;

  final DateTime? tglTenggat;

  final String? simulasiId;

  TugasFirebaseModel({
    this.tugasId,
    required this.kelasId,
    required this.dosenId,
    this.tglDibuat,
    required this.judul,
    this.deskripsi,
    this.tglTenggat, // Tipe DateTime
    this.simulasiId,
  });

  // --- Konversi ke/dari Map (untuk Firestore) ---

  factory TugasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
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
      dosenId: map['dosenId'] as String,
      tglDibuat: parseDateTime(map['tglDibuat']),
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String?,
      tglTenggat: parseDateTime(map['tglTenggat']),
      simulasiId: map['simulasiId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kelasId': kelasId,
      'dosenId': dosenId,
      'tglDibuat': tglDibuat != null
          ? Timestamp.fromDate(tglDibuat!)
          : FieldValue.serverTimestamp(),
      'judul': judul,
      'deskripsi': deskripsi,
      'tglTenggat': tglTenggat != null ? Timestamp.fromDate(tglTenggat!) : null,
      'simulasiId': simulasiId,
    };
  }

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
