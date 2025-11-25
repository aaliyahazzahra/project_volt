import 'dart:convert';

import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandlerFirebase {
  static const String currentUserKey = "current_user";

  // Save UserFirebaseModel pada saat login
  static Future<void> saveUser(UserFirebaseModel user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toMap());
    await prefs.setString(currentUserKey, userJson);
  }

  // Ambil UserFirebaseModel pada saat mau login / ke dashboard
  static Future<UserFirebaseModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(currentUserKey);

    if (userJson != null) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserFirebaseModel.fromMap(userMap);
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
