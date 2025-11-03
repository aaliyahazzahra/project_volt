class KelasModel {
  final int? id;
  final String namaKelas;
  final String? deskripsi;
  final String kodeKelas;
  final int dosenId;

  KelasModel({
    this.id,
    required this.namaKelas,
    this.deskripsi,
    required this.kodeKelas,
    required this.dosenId,
  });

  // Konversi dari Map (dari DB) ke KelasModel
  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      id: map['id'],
      namaKelas: map['nama_kelas'],
      deskripsi: map['deskripsi'],
      kodeKelas: map['kode_kelas'],
      dosenId: map['dosen_id'],
    );
  }

  // Konversi dari KelasModel ke Map (untuk insert ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'kode_kelas': kodeKelas,
      'dosen_id': dosenId,
    };
  }

  // copyWith untuk mempermudah update
  KelasModel copyWith({
    int? id,
    String? namaKelas,
    String? deskripsi,
    String? kodeKelas,
    int? dosenId,
  }) {
    return KelasModel(
      id: id ?? this.id,
      namaKelas: namaKelas ?? this.namaKelas,
      deskripsi: deskripsi ?? this.deskripsi,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      dosenId: dosenId ?? this.dosenId,
    );
  }
}
