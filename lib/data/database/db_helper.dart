import 'package:path/path.dart';
import 'package:project_volt/data/models/kelas_model.dart';
import 'package:project_volt/data/models/materi_model.dart';
import 'package:project_volt/data/models/submisi_model.dart';
import 'package:project_volt/data/models/tugas_model.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //untuk orangnya
  static const String tableUser = 'users';
  static const String tableMahasiswa = 'mahasiswa_profile';
  static const String tableDosen = 'dosen_profile';

  // untuk materi
  static const String tableMateri = 'materi';

  // untuk kelas & tugas
  static const String tableKelas = 'kelas';
  static const String tableTugas = 'tugas';
  static const String tableKelasAnggota = 'kelas_anggota';
  static const String tableSubmisi = 'submisi_tugas';

  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'volt_project.db'),
      onConfigure: (db) async {
        // Aktifkan foreign key constraints (untuk ON DELETE CASCADE)
        await db.execute('PRAGMA foreign_keys = ON');
      },
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

        // Buat tabel MATERI (dibuat oleh Dosen untuk Kelas)
        await db.execute(
          "CREATE TABLE $tableMateri("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "kelas_id INTEGER NOT NULL, "
          "judul TEXT NOT NULL, "
          "deskripsi TEXT, "
          "link_materi TEXT, " // Untuk link GDrive, Youtube, dll.
          "file_path_materi TEXT, "
          "tgl_posting TEXT NOT NULL, " // Simpan sebagai String (ISO format)
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

        // Buat tabel Submisi(dibuat oleh Dosen untuk Kelas)
        await db.execute(
          "CREATE TABLE $tableSubmisi("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "tugas_id INTEGER NOT NULL, "
          "mahasiswa_id INTEGER NOT NULL, "
          "link_submisi TEXT, "
          "file_path_submisi TEXT, "
          "nilai INTEGER DEFAULT 0, "
          "tgl_submit TEXT NOT NULL, "
          "FOREIGN KEY (tugas_id) REFERENCES $tableTugas (id) ON DELETE CASCADE, "
          "FOREIGN KEY (mahasiswa_id) REFERENCES $tableUser (id) ON DELETE CASCADE, "
          "UNIQUE(tugas_id, mahasiswa_id)"
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

  // Mengambil data spesifik untuk SATU tugas saja
  static Future<TugasModel?> getTugasById(int id) async {
    final dbs = await db();
    final results = await dbs.query(
      tableTugas,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      // Kembalikan SATU TugasModel
      return TugasModel.fromMap(results.first);
    }
    return null; // Kembalikan null jika tidak ditemukan (misal sudah dihapus)
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

  // MAHASISWA: Mengumpulkan atau memperbarui submisi
  static Future<int> createOrUpdateSubmisi(SubmisiModel submisi) async {
    final dbs = await db();
    // Gunakan 'replace' agar jika mahasiswa submit ulang, data lama tertimpa
    return await dbs.insert(
      tableSubmisi,
      submisi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // MAHASISWA: Mengecek submisi dia sebelumnya
  static Future<SubmisiModel?> getSubmisiByTugasAndMahasiswa(
    int tugasId,
    int mahasiswaId,
  ) async {
    final dbs = await db();
    final results = await dbs.query(
      tableSubmisi,
      where: 'tugas_id = ? AND mahasiswa_id = ?',
      whereArgs: [tugasId, mahasiswaId],
    );
    if (results.isNotEmpty) {
      return SubmisiModel.fromMap(results.first);
    }
    return null;
  }

  // DOSEN: Melihat semua submisi untuk satu tugas
  static Future<List<SubmisiModel>> getAllSubmisiByTugas(int tugasId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableSubmisi,
      where: 'tugas_id = ?',
      whereArgs: [tugasId],
      orderBy: 'tgl_submit DESC',
    );
    return results.map((map) => SubmisiModel.fromMap(map)).toList();
  }

  static Future<int> deleteSubmisiByTugasAndMahasiswa(
    int tugasId,
    int mahasiswaId,
  ) async {
    final dbs = await db();
    return await dbs.delete(
      tableSubmisi,
      where: 'tugas_id = ? AND mahasiswa_id = ?',
      whereArgs: [tugasId, mahasiswaId],
    );
  }

  // DOSEN: Melihat semua submisi (lengkap dengan data mahasiswa)
  static Future<List<SubmisiDetail>> getSubmisiDetailByTugas(
    int tugasId,
  ) async {
    final dbs = await db();
    // Kueri SQL untuk menggabungkan 3 tabel:
    // T1 = users (Nama, Email)
    // T2 = submisi_tugas (File, Link, Tanggal, Nilai)
    // T3 = mahasiswa_profile (NIM)
    final List<Map<String, dynamic>> results = await dbs.rawQuery(
      'SELECT T1.*, T2.*, T3.nim '
      'FROM $tableUser T1 '
      'INNER JOIN $tableSubmisi T2 ON T1.id = T2.mahasiswa_id '
      'LEFT JOIN $tableMahasiswa T3 ON T1.id = T3.user_id '
      'WHERE T2.tugas_id = ? '
      'ORDER BY T1.namaLengkap ASC', // Urutkan berdasarkan nama A-Z
      [tugasId],
    );

    List<SubmisiDetail> daftarSubmisi = [];
    for (var map in results) {
      daftarSubmisi.add(
        SubmisiDetail(
          submisi: SubmisiModel.fromMap(map),
          mahasiswa: UserModel.fromMap(map),
          nim: map['nim'],
        ),
      );
    }
    return daftarSubmisi;
  }

  // DOSEN: Membuat materi baru
  static Future<int> createMateri(MateriModel materi) async {
    final dbs = await db();
    return await dbs.insert(tableMateri, materi.toMap());
  }

  // DOSEN: Mengedit materi
  static Future<int> updateMateri(MateriModel materi) async {
    final dbs = await db();
    return await dbs.update(
      tableMateri,
      materi.toMap(),
      where: 'id = ?',
      whereArgs: [materi.id],
    );
  }

  // DOSEN: Menghapus materi
  static Future<int> deleteMateri(int materiId) async {
    final dbs = await db();
    return await dbs.delete(
      tableMateri,
      where: 'id = ?',
      whereArgs: [materiId],
    );
  }

  // MAHASISWA & DOSEN: Melihat semua materi di satu kelas
  static Future<List<MateriModel>> getMateriByKelas(int kelasId) async {
    final dbs = await db();
    final results = await dbs.query(
      tableMateri,
      where: 'kelas_id = ?',
      whereArgs: [kelasId],
      orderBy: 'id DESC',
    );
    return results.map((map) => MateriModel.fromMap(map)).toList();
  }

  // DOSEN: Mengambil data spesifik untuk satu kelas saja
  static Future<KelasModel?> getKelasById(int id) async {
    final dbs = await db();
    final results = await dbs.query(
      tableKelas,
      where: 'id = ?', // Filter berdasarkan ID kelas
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return KelasModel.fromMap(results.first);
    }
    return null;
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
      await dbs.insert(tableKelasAnggota, {
        'kelas_id': kelasId,
        'mahasiswa_id': mahasiswaId,
      }, conflictAlgorithm: ConflictAlgorithm.fail);
      return "Sukses: Berhasil bergabung dengan kelas!";
    } catch (e) {
      // error jika sudah join
      print(e);
      return "Error: Anda sudah terdaftar di kelas ini.";
    }
  }

  // MAHASISWA: Keluar dari kelas
  static Future<int> leaveKelas(int mahasiswaId, int kelasId) async {
    final dbs = await db();

    // Hapus data mahasiswa dari tabel anggota berdasarkan ID kelas dan ID mhs
    return await dbs.delete(
      tableKelasAnggota,
      where: 'kelas_id = ? AND mahasiswa_id = ?',
      whereArgs: [kelasId, mahasiswaId],
    );
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

    final List<Map<String, dynamic>> results = await dbs.rawQuery(
      'SELECT T1.*, T3.nim FROM $tableUser T1 '
      'INNER JOIN $tableKelasAnggota T2 ON T1.id = T2.mahasiswa_id '
      'LEFT JOIN $tableMahasiswa T3 ON T1.id = T3.user_id '
      'WHERE T2.kelas_id = ? '
      'ORDER BY T1.namaLengkap ASC',
      [kelasId],
    );

    // Konversi Map ke UserModel
    return results.map((map) => UserModel.fromMap(map)).toList();
  }
}

class SubmisiDetail {
  final SubmisiModel submisi;
  final UserModel mahasiswa;
  final String? nim;

  SubmisiDetail({required this.submisi, required this.mahasiswa, this.nim});
}
