// File: project_volt/data/firebase/models/user_firebase_model.dart

import 'dart:convert';

// Pilihan: enum bisa digunakan untuk Role, tapi tetap simpan string 'mahasiswa'/'dosen' di Firebase
enum UserRole { mahasiswa, dosen }

class UserFirebaseModel {
  // Properti Wajib dari Firebase Auth & Data Sesi
  final String uid;
  final String? token;
  final String email;

  // Properti Data Profil dari Firestore
  final String namaLengkap;
  final String role; // 'mahasiswa' atau 'dosen'

  // TAMBAHAN: Data Profil Kritis (diperlukan untuk fungsi inti aplikasi)
  final String? nimNidn; // NIM untuk Mahasiswa, NIDN/NIDK untuk Dosen
  final String? namaKampus;

  // Properti Tambahan (Metadata Firestore)
  final String? createdAt;
  final String? updatedAt;

  UserFirebaseModel({
    required this.uid,
    this.token,
    required this.namaLengkap,
    required this.email,
    required this.role,
    this.nimNidn,
    this.namaKampus,
    this.createdAt,
    this.updatedAt,
  });

  // ----------------------------------------------------
  // 1. METHOD KRUSIAL: copyWith (Untuk State Update)
  // ----------------------------------------------------
  /// Membuat instance UserFirebaseModel baru, menyalin field lama
  /// kecuali field yang diberikan nilai baru.
  UserFirebaseModel copyWith({
    String? uid,
    String? token,
    String? email,
    String? namaLengkap,
    String? role,
    String? nimNidn,
    String? namaKampus,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserFirebaseModel(
      uid: uid ?? this.uid,
      token: token ?? this.token,
      email: email ?? this.email,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      role: role ?? this.role,

      // Field yang di-update di Edit Profil
      nimNidn: nimNidn ?? this.nimNidn,
      namaKampus: namaKampus ?? this.namaKampus,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ----------------------------------------------------
  // 2. Konversi ke Map (untuk penyimpanan Firestore/JSON)
  // ----------------------------------------------------
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'token': token,
      'namaLengkap': namaLengkap,
      'email': email,
      'role': role,
      'nimNidn': nimNidn,
      'namaKampus': namaKampus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // ----------------------------------------------------
  // 3. Konversi dari Map (dari Firestore)
  // ----------------------------------------------------
  factory UserFirebaseModel.fromMap(Map<String, dynamic> map) {
    // Pengecekan Integritas Data Wajib (UID dan Role harus ada)
    final String? requiredUid = map['uid'] as String?;
    final String? requiredRole = map['role'] as String?;

    if (requiredUid == null || requiredRole == null) {
      // Melempar error agar kita tahu jika data tidak valid saat di-load
      throw StateError("Data Integritas Gagal: UID atau Role tidak ditemukan.");
    }

    return UserFirebaseModel(
      uid: requiredUid,
      token: map['token'] as String?,
      namaLengkap:
          (map['namaLengkap'] as String?) ?? 'Pengguna', // Memberi default
      email: (map['email'] as String?) ?? '', // Memberi default
      role: requiredRole,

      // Field yang mungkin null (opsional)
      nimNidn: map['nimNidn'] as String?,
      namaKampus: map['namaKampus'] as String?,

      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  // ----------------------------------------------------
  // 4. Konversi ke/dari JSON String (untuk SharedPreferences/Local Storage)
  // ----------------------------------------------------
  String toJson() => json.encode(toMap());

  factory UserFirebaseModel.fromJson(String source) =>
      UserFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
