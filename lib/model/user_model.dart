enum UserRole { mahasiswa, dosen }

class UserModel {
  final int? id;
  final String namaLengkap;
  final String email;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.role,
  });

  // Konversi dari Map (dari DB) ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      namaLengkap: map['namaLengkap'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }

  // Konversi dari UserModel ke Map (untuk insert ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
