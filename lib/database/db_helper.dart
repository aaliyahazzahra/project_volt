import 'package:path/path.dart';
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
          "kode_kelas TEXT NOT NULL UNIQUE, " // Kode unik untuk join
          "dosen_id INTEGER NOT NULL, " // Siapa pembuat/pemilik kelas
          "FOREIGN KEY (dosen_id) REFERENCES $tableUser (id) ON DELETE CASCADE"
          ")",
        );
        // Buat tabel TUGAS (dibuat oleh Dosen untuk Kelas)
        await db.execute(
          "CREATE TABLE $tableTugas("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "kelas_id INTEGER NOT NULL, " // Tugas ini milik kelas mana
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
  static Future<int> createKelas(Map<String, dynamic> data) async {
    final dbs = await db();
    return await dbs.insert(
      tableKelas,
      data,
      conflictAlgorithm: ConflictAlgorithm.fail,
    ); // Gagal jika kode_kelas sama
  }

  // DOSEN: Mendapatkan semua kelas yang dia buat
  static Future<List<Map<String, dynamic>>> getKelasByDosen(int dosenId) async {
    final dbs = await db();
    return await dbs.query(
      tableKelas,
      where: 'dosen_id = ?',
      whereArgs: [dosenId],
      orderBy: 'nama_kelas ASC', // Diurutkan A-Z
    );
  }

  // DOSEN: Membuat tugas baru
  static Future<int> createTugas(Map<String, dynamic> data) async {
    final dbs = await db();
    return await dbs.insert(tableTugas, data);
  }

  // DOSEN: Mengedit tugas
  static Future<int> updateTugas(int tugasId, Map<String, dynamic> data) async {
    final dbs = await db();
    return await dbs.update(
      tableTugas,
      data,
      where: 'id = ?',
      whereArgs: [tugasId],
    );
  }

  // DOSEN: Menghapus tugas
  static Future<int> deleteTugas(int tugasId) async {
    final dbs = await db();
    return await dbs.delete(tableTugas, where: 'id = ?', whereArgs: [tugasId]);
  }

  // MAHASISWA & DOSEN: Melihat semua tugas di satu kelas
  static Future<List<Map<String, dynamic>>> getTugasByKelas(int kelasId) async {
    final dbs = await db();
    return await dbs.query(
      tableTugas,
      where: 'kelas_id = ?',
      whereArgs: [kelasId],
      orderBy: 'id DESC', // Tampilkan yang terbaru di atas
    );
  }
}
