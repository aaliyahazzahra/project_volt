class SubmisiModel {
  final int? id;
  final int tugasId;
  final int mahasiswaId;
  final String? linkSubmisi;
  final String? filePathSubmisi;
  final String tglSubmit;
  final int? nilai; // 0 = belum dinilai

  SubmisiModel({
    this.id,
    required this.tugasId,
    required this.mahasiswaId,
    this.linkSubmisi,
    this.filePathSubmisi,
    required this.tglSubmit,
    this.nilai,
  });

  // Konversi dari Map (DB) ke Model
  factory SubmisiModel.fromMap(Map<String, dynamic> map) {
    return SubmisiModel(
      id: map['id'],
      tugasId: map['tugas_id'],
      mahasiswaId: map['mahasiswa_id'],
      linkSubmisi: map['link_submisi'],
      filePathSubmisi: map['file_path_submisi'],
      tglSubmit: map['tgl_submit'],
      nilai: map['nilai'],
    );
  }

  // Konversi dari Model ke Map (untuk DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tugas_id': tugasId,
      'mahasiswa_id': mahasiswaId,
      'link_submisi': linkSubmisi,
      'file_path_submisi': filePathSubmisi,
      'tgl_submit': tglSubmit,
      'nilai': nilai,
    };
  }
}
