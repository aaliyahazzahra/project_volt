import 'dart:convert';

class MateriFirebaseModel {
  final String? materiId;
  final String kelasId;
  final String judul;
  final String? deskripsi;
  final String? linkMateri;
  final String? filePathMateri;
  final String tglPosting;
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

  factory MateriFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MateriFirebaseModel(
      materiId: id,
      kelasId: map['kelasId'] as String,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String?,
      linkMateri: map['linkMateri'] as String?,
      filePathMateri: map['filePathMateri'] as String?,
      tglPosting: map['tglPosting'] as String,
      simulasiId: map['simulasiId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kelasId': kelasId,
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

  String toJson() => json.encode(toMap());

  factory MateriFirebaseModel.fromJson(String source) =>
      MateriFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
