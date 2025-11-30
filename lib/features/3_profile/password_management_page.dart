import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart'; //perubahan: Import AppColor

class PasswordManagementPage extends StatefulWidget {
  const PasswordManagementPage({super.key});

  @override
  State<PasswordManagementPage> createState() => _PasswordManagementPageState();
}

class _PasswordManagementPageState extends State<PasswordManagementPage> {
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _message = '';

  // --- FUNGSI 1: MENGIRIM EMAIL RESET PASSWORD (LUPA PASSWORD) ---

  Future<void> sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = 'Masukkan alamat email Anda.');
      return;
    }

    setState(() => _message = 'Mengirim email...');

    try {
      // Ini adalah fungsi utama untuk mengirim tautan unik (link) reset password.
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _message =
            '✅ Email reset password telah dikirim ke $email. Cek inbox Anda.';
      });
      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      // Tangani error seperti 'user-not-found'
      setState(() {
        _message = 'Gagal mengirim email: ${e.message ?? 'Terjadi kesalahan'}';
      });
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan tak terduga: $e';
      });
    }
  }

  // --- FUNGSI 2: MENGGANTI PASSWORD SAAT PENGGUNA SUDAH LOGIN ---

  Future<void> updatePasswordForLoggedInUser() async {
    final user = _auth.currentUser;
    final newPassword = _newPasswordController.text;
    final oldPassword = _oldPasswordController.text;

    if (user == null) {
      setState(() => _message = 'Anda harus login untuk mengganti password.');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _message = 'Password baru minimal 6 karakter.');
      return;
    }

    setState(() => _message = 'Memperbarui password...');

    try {
      // 1. RE-AUTENTIKASI (Penting untuk Keamanan!)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. MENGGANTI PASSWORD
      await user.updatePassword(newPassword);

      setState(() {
        _message = '🎉 Password berhasil diganti!';
      });
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() => _message = 'Password lama salah.');
      } else if (e.code == 'requires-recent-login') {
        setState(
          () => _message =
              'Mohon login kembali untuk mengizinkan perubahan password.',
        );
      } else {
        setState(() {
          _message =
              'Gagal ganti password: ${e.message ?? 'Terjadi kesalahan'}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor, //perubahan
      appBar: AppBar(
        title: const Text(
          'Manajemen Password',
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ), //perubahan
        backgroundColor: AppColor.kAppBar, //perubahan
        iconTheme: const IconThemeData(color: AppColor.kTextColor), //perubahan
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Bagian Pesan Status ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Mengganti Colors.blueGrey.shade50
                color: AppColor
                    .kLightAccentColor, //perubahan: Menggunakan warna terang Mahasiswa (Biru)
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.kAccentColor.withOpacity(0.5),
                ), //perubahan
              ),
              child: Text(
                _message.isEmpty ? 'Pilih salah satu opsi di bawah.' : _message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.kTextColor,
                ), //perubahan
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // --- BAGIAN 1: LUPA PASSWORD (RESET VIA EMAIL LINK) ---
            // -----------------------------------------------------------------
            const Text(
              '1. Lupa Password (Reset via Link)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ), //perubahan
            ),
            const Divider(color: AppColor.kDividerColor), //perubahan
            const Text(
              'Masukkan email terdaftar untuk menerima tautan (link) reset password.',
              style: TextStyle(color: AppColor.kTextSecondaryColor), //perubahan
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Terdaftar',
                labelStyle: const TextStyle(
                  color: AppColor.kTextSecondaryColor,
                ), //perubahan
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kAccentColor,
                    width: 2.0,
                  ),
                ), //perubahan
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Kirim Email Reset Password'),
              onPressed: sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColor.kAccentColor, //perubahan: Menggunakan Biru Aksen
                foregroundColor: AppColor.kWhiteColor, //perubahan
              ),
            ),

            // -----------------------------------------------------------------
            const SizedBox(height: 40),
            // -----------------------------------------------------------------

            // -----------------------------------------------------------------
            // --- BAGIAN 2: GANTI PASSWORD SAAT SUDAH LOGIN ---
            // -----------------------------------------------------------------
            const Text(
              '2. Ganti Password (Saat Sudah Login)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ), //perubahan
            ),
            const Divider(color: AppColor.kDividerColor), //perubahan
            Text(
              'Status Login: ${_auth.currentUser != null ? '✅ Login sebagai ${_auth.currentUser!.email}' : '❌ Belum Login'}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColor.kTextSecondaryColor,
              ), //perubahan
            ),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                labelStyle: const TextStyle(
                  color: AppColor.kTextSecondaryColor,
                ), //perubahan
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kPrimaryColor,
                    width: 2.0,
                  ),
                ), //perubahan: Menggunakan Orange/Primary
              ),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru (min 6 karakter)',
                labelStyle: const TextStyle(
                  color: AppColor.kTextSecondaryColor,
                ), //perubahan
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColor.kPrimaryColor,
                    width: 2.0,
                  ),
                ), //perubahan
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text('Ganti Password'),
              onPressed: updatePasswordForLoggedInUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor
                    .kPrimaryColor, //perubahan: Menggunakan Orange/Primary
                foregroundColor: AppColor.kWhiteColor, //perubahan
              ),
            ),
            // -----------------------------------------------------------------
          ],
        ),
      ),
    );
  }
}
