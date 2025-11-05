import 'package:path/path.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/tugas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const String tableUser = 'users';
  static const String tableMahasiswa = 'mahasiswa_profile';
  static const String tableDosen = 'dosen_profile';

  // untuk kelas & tugas
  static const String tableKelas = 'kelas';
  static const String tableTugas = 'tugas';
  static const String tableKelasAnggota = 'kelas_anggota';

  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'volt_project.db'),
      onCreate: (db, version) async {
        // Buat tabel users
        await db.execute(
          "CREATE TABLE $tableUser("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "namaLengkap TEXT NOT NULL, "
          "email TEXT NOT NULL UNIQUE, "
          "password TEXT NOT NULL, "
          "role TEXT NOT NULL"
          ")",
        );

        // Buat tabel mahasiswa
        await db.execute(
          "CREATE TABLE $tableMahasiswa("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "user_id INTEGER NOT NULL UNIQUE, "
          "nama_kampus TEXT, "
          "nim TEXT, "
          "FOREIGN KEY (user_id) REFERENCES $tableUser (id) ON DELETE CASCADE"
          ")",
        );

        // Buat tabel dosen
        await db.execute(
          "CREATE TABLE $tableDosen("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "user_id INTEGER NOT NULL UNIQUE, "
          "nama_kampus TEXT, "
          "nidn_nidk TEXT, "
          "FOREIGN KEY (user_id) REFERENCES $tableUser (id) ON DELETE CASCADE"
          ")",
        );
        // Buat tabel KELAS (dibuat oleh Dosen)
        await db.execute(
          "CREATE TABLE $tableKelas("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "nama_kelas TEXT NOT NULL, "
          "deskripsi TEXT, "
          "kode_kelas TEXT NOT NULL UNIQUE, "
          "dosen_id INTEGER NOT NULL, "
          "FOREIGN KEY (dosen_id) REFERENCES $tableUser (id) ON DELETE CASCADE"
          ")",
        );
        // Buat tabel TUGAS (dibuat oleh Dosen untuk Kelas)
        await db.execute(
          "CREATE TABLE $tableTugas("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "kelas_id INTEGER NOT NULL, "
          "judul TEXT NOT NULL, "
          "deskripsi TEXT, "
          "tgl_tenggat TEXT, " // Simpan sebagai String (ISO format)
          "FOREIGN KEY (kelas_id) REFERENCES $tableKelas (id) ON DELETE CASCADE"
          ")",
        );

        // Buat tabel Anggota Kelas (diisi oleh Mahasiswa)
        await db.execute(
          "CREATE TABLE $tableKelasAnggota("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "kelas_id INTEGER NOT NULL, "
          "mahasiswa_id INTEGER NOT NULL, "
          "FOREIGN KEY (kelas_id) REFERENCES $tableKelas (id) ON DELETE CASCADE, "
          "FOREIGN KEY (mahasiswa_id) REFERENCES $tableUser (id) ON DELETE CASCADE, "
          "UNIQUE(kelas_id, mahasiswa_id)" // 1 mhs hanya bisa join 1x per kelas
          ")",
        );
      },
      version: 1,
    );
  }

  static Future<bool> registerUser(UserModel user) async {
    final dbs = await db();
    try {
      await dbs.insert(
        tableUser,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.query(
      tableUser,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  static Future<void> saveMahasiswaProfile(Map<String, dynamic> data) async {
    final dbs = await db();
    await dbs.insert(
      tableMahasiswa,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> saveDosenProfile(Map<String, dynamic> data) async {
    final dbs = await db();
    await dbs.insert(
      tableDosen,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getMahasiswaProfile(int userId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableMahasiswa,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getDosenProfile(int userId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableDosen,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // DOSEN: Membuat kelas baru
  static Future<int> createKelas(KelasModel kelas) async {
    final dbs = await db();
    return await dbs.insert(
      tableKelas,
      kelas.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    ); // Gagal jika kode_kelas sama
  }

  // UPDATE KELAS
  static Future<int> updateKelas(KelasModel kelas) async {
    final dbs = await db();
    final id = kelas.id;
    return await dbs.update(
      tableKelas,
      kelas.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // HAPUS KELAS
  static Future<int> deleteKelas(int id) async {
    final dbs = await db();
    return await dbs.delete(tableKelas, where: 'id = ?', whereArgs: [id]);
  }

  // DOSEN: Mendapatkan semua kelas yang dia buat
  static Future<List<KelasModel>> getKelasByDosen(int dosenId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableKelas,
      where: 'dosen_id = ?',
      whereArgs: [dosenId],
      orderBy: 'nama_kelas ASC', // Diurutkan A-Z
    );

    return results.map((map) => KelasModel.fromMap(map)).toList();
  }

  // DOSEN: Membuat tugas baru
  static Future<int> createTugas(TugasModel tugas) async {
    final dbs = await db();
    return await dbs.insert(tableTugas, tugas.toMap());
  }

  // DOSEN: Mengedit tugas
  static Future<int> updateTugas(TugasModel tugas) async {
    final dbs = await db();
    return await dbs.update(
      tableTugas,
      tugas.toMap(),
      where: 'id = ?',
      whereArgs: [tugas.id],
    );
  }

  // DOSEN: Menghapus tugas
  static Future<int> deleteTugas(int tugasId) async {
    final dbs = await db();
    return await dbs.delete(tableTugas, where: 'id = ?', whereArgs: [tugasId]);
  }

  // MAHASISWA & DOSEN: Melihat semua tugas di satu kelas
  static Future<List<TugasModel>> getTugasByKelas(int kelasId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableTugas,
      where: 'kelas_id = ?',
      whereArgs: [kelasId],
      orderBy: 'id DESC', // Tampilkan yang terbaru di atas
    );
    return results.map((map) => TugasModel.fromMap(map)).toList();
  }

  // MAHASISWA: Bergabung dengan kelas
  static Future<String> joinKelas(int mahasiswaId, String kodeKelas) async {
    final dbs = await db();

    // Cari kelas berdasarkan kode
    final List<Map<String, dynamic>> kelasResults = await dbs.query(
      tableKelas,
      where: 'kode_kelas = ?',
      whereArgs: [kodeKelas],
    );

    // Cek jika kelas tidak ada
    if (kelasResults.isEmpty) {
      return "Error: Kode Kelas tidak ditemukan.";
    }
    final int kelasId = kelasResults.first['id'];

    // Masukkan ke tabel anggota
    try {
      await dbs.insert(
        tableKelasAnggota,
        {'kelas_id': kelasId, 'mahasiswa_id': mahasiswaId},
        conflictAlgorithm: ConflictAlgorithm.fail, // Gagal jika sudah join
      );
      return "Sukses: Berhasil bergabung dengan kelas!";
    } catch (e) {
      // error jika sudah join
      print(e);
      return "Error: Anda sudah terdaftar di kelas ini.";
    }
  }

  // MAHASISWA: Mendapatkan semua kelas yang dia ikuti
  static Future<List<KelasModel>> getKelasByMahasiswa(int mahasiswaId) async {
    final dbs = await db();
    final List<Map<String, dynamic>> results = await dbs.rawQuery(
      'SELECT T1.* FROM $tableKelas T1 '
      'INNER JOIN $tableKelasAnggota T2 ON T1.id = T2.kelas_id '
      'WHERE T2.mahasiswa_id = ?',
      [mahasiswaId],
    );
    return results.map((map) => KelasModel.fromMap(map)).toList();
  }

  // Untuk tab Anggota
  static Future<List<UserModel>> getAnggotaByKelas(int kelasId) async {
    final dbs = await db();

    // join mengambil data user (T1) yang terhubung ke kelas_anggota (T2) dengan kelas_id cocok
    final List<Map<String, dynamic>> results = await dbs.rawQuery(
      'SELECT T1.* FROM $tableUser T1 '
      'INNER JOIN $tableKelasAnggota T2 ON T1.id = T2.mahasiswa_id '
      'WHERE T2.kelas_id = ?'
      'ORDER BY T1.namaLengkap ASC', // <-- PERUBAHAN DI SINI

      [kelasId],
    );

    // Konversi Map ke UserModel
    return results.map((map) => UserModel.fromMap(map)).toList();
  }
}
