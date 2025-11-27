import 'dart:convert';

enum UserRole { mahasiswa, dosen }

class UserFirebaseModel {
  // Properti Wajib dari Firebase Auth & Data Sesi
  final String uid;
  final String? token;
  final String email;

  // Properti Data Profil dari Firestore
  final String namaLengkap;
  final String role;

  //  TAMBAHAN: Data Profil Kritis (diperlukan untuk fungsi inti aplikasi)
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

  // TAMBAHKAN METHOD copyWith
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
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      role: role ?? this.role,
      nimNidn: nimNidn ?? this.nimNidn,
      namaKampus: namaKampus ?? this.namaKampus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Konversi ke/dari Map

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

  factory UserFirebaseModel.fromMap(Map<String, dynamic> map) {
    // uid: map['uid'] as String?,
    final String? requiredUid = map['uid'] as String?;
    // token: map['token'] as String?,
    final String? requiredRole = map['role'] as String?;
    if (requiredUid == null || requiredRole == null) {
      // Melempar error dengan pesan yang jelas
      throw StateError("Data Integritas Gagal");
    }
    return UserFirebaseModel(
      uid: requiredUid,
      // namaLengkap: map['namaLengkap'] as String?,
      namaLengkap: (map['namaLengkap'] as String?) ?? 'Pengguna',
      // email: map['email'] as String?,
      email: (map['email'] as String?) ?? '',
      // role: map['role'] as String?,
      role: requiredRole,
      nimNidn: map['nimNidn'] as String?,
      namaKampus: map['namaKampus'] as String?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  // Konversi ke/dari JSON String (untuk penyimpanan SharedPreferences)

  String toJson() => json.encode(toMap());

  factory UserFirebaseModel.fromJson(String source) =>
      UserFirebaseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
