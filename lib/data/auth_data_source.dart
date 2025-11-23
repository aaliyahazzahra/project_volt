import 'package:project_volt/core/utils/preference_handler.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/user_model.dart';

class AuthDataSource {
  // Method untuk Pendaftaran
  Future<bool> registerUser(UserModel newUser) async {
    return await DbHelper.registerUser(newUser);
  }

  // Method untuk Login
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    return await DbHelper.loginUser(email: email, password: password);
  }

  // Method untuk Logout
  Future<void> logout() async {
    await PreferenceHandler.removeUser();
  }
}
