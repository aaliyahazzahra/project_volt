class MateriModel {
  final int? id;
  final int kelasId;
  final String judul;
  final String? deskripsi;
  final String? linkMateri;
  final String? filePathMateri;
  final String tglPosting; // ISO String format

  MateriModel({
    this.id,
    required this.kelasId,
    required this.judul,
    this.deskripsi,
    this.linkMateri,
    this.filePathMateri,
    required this.tglPosting,
  });

  // Konversi dari Map (data dari DB) ke Model
  factory MateriModel.fromMap(Map<String, dynamic> map) {
    return MateriModel(
      id: map['id'],
      kelasId: map['kelas_id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      linkMateri: map['link_materi'],
      filePathMateri: map['file_path_materi'],
      tglPosting: map['tgl_posting'],
    );
  }

  // Konversi dari Model ke Map (untuk disimpan ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kelas_id': kelasId,
      'judul': judul,
      'deskripsi': deskripsi,
      'link_materi': linkMateri,
      'file_path_materi': filePathMateri,
      'tgl_posting': tglPosting,
    };
  }
}
