enum UserRole { mahasiswa, dosen }

class UserModel {
  final int? id;
  final String email;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  // Fungsi untuk mengubah object UserModel menjadi Map (untuk disimpan ke DB)
  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'password': password, 'role': role};
  }

  // Fungsi untuk mengubah Map (dari DB) menjadi object UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
