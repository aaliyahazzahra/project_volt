import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/kelas_model.dart';

class KelasDataSource {
  // 1. Mengambil Daftar Kelas Dosen
  Future<List<KelasModel>> getKelasByDosen(int dosenId) async {
    return await DbHelper.getKelasByDosen(dosenId);
  }

  // 2. Menghapus Kelas
  Future<int> deleteKelas(int kelasId) async {
    return await DbHelper.deleteKelas(kelasId);
  }

  // 3. Mengecek Profil Dosen
  Future<Map<String, dynamic>?> getDosenProfile(int userId) async {
    return await DbHelper.getDosenProfile(userId);
  }

  // 5. Mengambil Kelas Mahasiswa
  Future<List<KelasModel>> getKelasByMahasiswa(int mahasiswaId) async {
    return await DbHelper.getKelasByMahasiswa(mahasiswaId);
  }

  // 6. Bergabung dengan Kelas
  Future<String> joinKelas(int mahasiswaId, String kodeKelas) async {
    return await DbHelper.joinKelas(mahasiswaId, kodeKelas);
  }

  // 7. Keluar dari Kelas
  Future<int> leaveKelas(int mahasiswaId, int kelasId) async {
    return await DbHelper.leaveKelas(mahasiswaId, kelasId);
  }

  // 8. Mengecek Profil Mahasiswa
  Future<Map<String, dynamic>?> getMahasiswaProfile(int userId) async {
    return await DbHelper.getMahasiswaProfile(userId);
  }
}
