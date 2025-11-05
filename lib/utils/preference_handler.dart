import 'dart:convert'; // 1. Kita butuh 'convert' untuk JSON

import 'package:project_volt/model/user_model.dart'; // 2. Kita butuh model kita
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  // 3. Kita ganti key-nya
  static const String currentUserKey = "current_user";

  // Save UserModel pada saat login
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // 4. Ubah UserModel menjadi Map, lalu ubah Map menjadi JSON String
    String userJson = jsonEncode(user.toMap());
    await prefs.setString(currentUserKey, userJson);
  }

  // Ambil UserModel pada saat mau login / ke dashboard
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    // 5. Ambil data sebagai String
    String? userJson = prefs.getString(currentUserKey);

    if (userJson != null) {
      try {
        // 6. Ubah JSON String kembali menjadi Map, lalu jadi UserModel
        Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserModel.fromMap(userMap);
      } catch (e) {
        // Jika data di SharedPreferences rusak, hapus data itu
        print("Gagal parse user: $e");
        await removeUser();
        return null;
      }
    }
    return null; // Tidak ada user yang login
  }

  // Hapus data login pada saat logout
  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
  }
}
