import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_volt/data/simulation_models.dart';

// ------------------------------------------------------------------------
// MODEL INDUK: Merepresentasikan data simulasi sebagai konten di VOLT
// ------------------------------------------------------------------------

class SimulasiFirebaseModel {
  // Metadata VOLT
  final String? simulasiId; // ID Dokumen Firebase
  final String kelasId;
  final String dosenId;
  String judul;
  String deskripsi;

  // Konten Utama Simulasi (Model yang Anda buat sebelumnya)
  // Perubahan: SimulationProject harus bisa diubah ke/dari JSON/Map
  final SimulationProject projectData;

  final Timestamp? tglDibuat;

  SimulasiFirebaseModel({
    this.simulasiId,
    required this.kelasId,
    required this.dosenId,
    required this.judul,
    this.deskripsi = '',
    required this.projectData,
    this.tglDibuat,
  });

  // ----------------------------------------------------
  // Konversi ke/dari Firebase (Map)
  // ----------------------------------------------------

  factory SimulasiFirebaseModel.fromMap(Map<String, dynamic> map, String id) {
    // Membangun SimulationProject dari data JSON
    final projectMap = map['project_data'] as Map<String, dynamic>? ?? {};
    final project = SimulationProject.fromMap(projectMap);

    return SimulasiFirebaseModel(
      simulasiId: id,
      kelasId: map['kelas_id'] ?? '',
      dosenId: map['dosen_id'] ?? '',
      judul: map['judul'] ?? 'Simulasi Tanpa Judul',
      deskripsi: map['deskripsi'] ?? '',
      projectData: project,
      tglDibuat: map['tgl_dibuat'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kelas_id': kelasId,
      'dosen_id': dosenId,
      'judul': judul,
      'deskripsi': deskripsi,
      'project_data': projectData.toMap(), // Harus bisa dikonversi ke Map
      'tgl_dibuat': tglDibuat ?? FieldValue.serverTimestamp(),
    };
  }
}
