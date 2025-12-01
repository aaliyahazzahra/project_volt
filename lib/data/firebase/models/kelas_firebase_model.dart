import 'dart:convert';

class KelasFirebaseModel {
  // ID dokumen di Firestore (String unik)
  final String? kelasId;
  final String namaKelas;
  final String? deskripsi;
  final String kodeKelas;
  // ID Pengguna dari Firebase Auth (UID, tipe String)
  final String dosenUid;

  final int jumlahMahasiswa;

  KelasFirebaseModel({
    this.kelasId,
    required this.namaKelas,
    this.deskripsi,
    required this.kodeKelas,
    required this.dosenUid,
    this.jumlahMahasiswa = 0,
  });

  // Konversi dari Map (dari Firestore) ke KelasFirebaseModel
  factory KelasFirebaseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final int count = map['jumlahMahasiswa'] as int? ?? 0;

    return KelasFirebaseModel(
      kelasId: id,
      namaKelas: map['nama_kelas'] as String,
      deskripsi: map['deskripsi'] as String?,
      kodeKelas: map['kode_kelas'] as String,
      dosenUid: map['dosenUid'] as String,

      jumlahMahasiswa: count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'kode_kelas': kodeKelas,
      'dosenUid': dosenUid,
    };
  }

  // copyWith untuk mempermudah update
  KelasFirebaseModel copyWith({
    String? kelasId,
    String? namaKelas,
    String? deskripsi,
    String? kodeKelas,
    String? dosenUid,
    int? jumlahMahasiswa,
  }) {
    return KelasFirebaseModel(
      kelasId: kelasId ?? this.kelasId,
      namaKelas: namaKelas ?? this.namaKelas,
      deskripsi: deskripsi ?? this.deskripsi,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      dosenUid: dosenUid ?? this.dosenUid,

      jumlahMahasiswa: jumlahMahasiswa ?? this.jumlahMahasiswa,
    );
  }

  String toJson() => json.encode(toMap());

  factory KelasFirebaseModel.fromJson(String source) =>
      KelasFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
