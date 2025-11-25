// File: project_volt/data/firebase/models/user_firebase_model.dart

import 'dart:convert';

class UserFirebaseModel {
  // Properti Wajib dari Firebase Auth & Data Sesi
  final String? uid;
  final String? token;
  final String? email;

  // Properti Data Profil dari Firestore
  final String? namaLengkap;
  final String? role;

  // 🔥 TAMBAHAN: Data Profil Kritis (diperlukan untuk fungsi inti aplikasi)
  final String? nimNidn; // NIM untuk Mahasiswa, NIDN/NIDK untuk Dosen
  final String? namaKampus;

  // Properti Tambahan (Metadata Firestore)
  final String? createdAt;
  final String? updatedAt;

  UserFirebaseModel({
    this.uid,
    this.token,
    this.namaLengkap,
    this.email,
    this.role,
    this.nimNidn, // <-- Tambah di constructor
    this.namaKampus, // <-- Tambah di constructor
    this.createdAt,
    this.updatedAt,
  });

  // --- Konversi ke/dari Map ---

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'token': token,
      'namaLengkap': namaLengkap,
      'email': email,
      'role': role,
      'nimNidn': nimNidn, // <-- Tambah di toMap
      'namaKampus': namaKampus, // <-- Tambah di toMap
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserFirebaseModel.fromMap(Map<String, dynamic> map) {
    return UserFirebaseModel(
      uid: map['uid'] as String?,
      token: map['token'] as String?,
      namaLengkap: map['namaLengkap'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String?,
      nimNidn: map['nimNidn'] as String?, // <-- Tambah di fromMap
      namaKampus: map['namaKampus'] as String?, // <-- Tambah di fromMap
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  // --- Konversi ke/dari JSON String (untuk penyimpanan SharedPreferences) ---

  String toJson() => json.encode(toMap());

  factory UserFirebaseModel.fromJson(String source) =>
      UserFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
