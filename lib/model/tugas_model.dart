class TugasModel {
  final int? id;
  final int kelasId;
  final String judul;
  final String? deskripsi;
  final String? tglTenggat;

  TugasModel({
    this.id,
    required this.kelasId,
    required this.judul,
    this.deskripsi,
    this.tglTenggat,
  });

  factory TugasModel.fromMap(Map<String, dynamic> map) {
    return TugasModel(
      id: map['id'],
      kelasId: map['kelas_id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      tglTenggat: map['tgl_tenggat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kelas_id': kelasId,
      'judul': judul,
      'deskripsi': deskripsi,
      'tgl_tenggat': tglTenggat,
    };
  }

  // Fungsi copyWith untuk mempermudah update
  TugasModel copyWith({
    int? id,
    int? kelasId,
    String? judul,
    String? deskripsi,
    String? tglTenggat,
  }) {
    return TugasModel(
      id: id ?? this.id,
      kelasId: kelasId ?? this.kelasId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tglTenggat: tglTenggat ?? this.tglTenggat,
    );
  }
}
