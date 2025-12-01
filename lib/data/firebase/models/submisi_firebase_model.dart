import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SubmisiFirebaseModel {
  final String? submisiId;
  final String tugasId;
  final String mahasiswaId;

  final String? textSubmisi;

  final String? linkSubmisi;
  final String? filePathSubmisi;

  final String? simulasiSubmisiId;

  final DateTime? tglSubmit;

  final String status;

  final int? nilai; // 0-100

  SubmisiFirebaseModel({
    this.submisiId,
    required this.tugasId,
    required this.mahasiswaId,
    this.textSubmisi,
    this.linkSubmisi,
    this.filePathSubmisi,
    this.simulasiSubmisiId,
    this.tglSubmit,
    this.status = 'DRAFT',
    this.nilai,
  });

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
      textSubmisi: map['textSubmisi'] as String?,
      linkSubmisi: map['linkSubmisi'] as String?,
      filePathSubmisi: map['filePathSubmisi'] as String?,
      simulasiSubmisiId: map['simulasiSubmisiId'] as String?,
      tglSubmit: parseDateTime(map['tglSubmit']),
      status: map['status'] as String? ?? 'DRAFT',
      nilai: map['nilai'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tugasId': tugasId,
      'mahasiswaId': mahasiswaId,
      'textSubmisi': textSubmisi, // SIMPAN TEXT SUBMISI
      'linkSubmisi': linkSubmisi,
      'filePathSubmisi': filePathSubmisi,
      'simulasiSubmisiId': simulasiSubmisiId,
      'tglSubmit': tglSubmit != null ? Timestamp.fromDate(tglSubmit!) : null,
      'status': status,
      'nilai': nilai,
    };
  }

  SubmisiFirebaseModel copyWith({
    String? submisiId,
    String? tugasId,
    String? mahasiswaId,
    String? textSubmisi,
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
      textSubmisi: textSubmisi ?? this.textSubmisi,
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
