import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_data.dart' as AppData;
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/firebase.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/widgets/firebase/rolebuttonfirebase.dart';
import 'package:project_volt/widgets/primary_auth_button.dart';

class RegisterFormFirebase extends StatefulWidget {
  const RegisterFormFirebase({super.key});

  @override
  State<RegisterFormFirebase> createState() => _RegisterFormFirebaseState();
}

class _RegisterFormFirebaseState extends State<RegisterFormFirebase> {
  final _formKey = GlobalKey<FormState>();
  // SQF CODE: final AuthDataSource _authDataSource = AuthDataSource();
  final Logger logger = Logger(
    printer: PrettyPrinter(
      // Anda bisa mengatur kustomisasi di sini
      methodCount: 0, // Tidak menampilkan jumlah method call
      errorMethodCount: 5, // Tampilkan 5 method call saat error
      lineLength: 80,
      colors: true, // Pastikan berwarna
      printTime: true, // Tampilkan waktu log
    ),
  );

  UserRole _selectedRole = UserRole.mahasiswa;
  bool _isLoading = false;

  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nimNidnController =
      TextEditingController(); // Controller baru
  String? _selectedKampus;
  final List<String> daftarKampus = AppData.daftarKampus;

  @override
  void dispose() {
    namaLengkapController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Set State Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // SQF CODE:
      // UserModel newUser = UserModel(
      //   namaLengkap: namaLengkapController.text,
      //   email: emailController.text,
      //   password: passwordController.text,
      //   role: _selectedRole.toString(),
      // );

      // Mengambil role dalam bentuk string yang bersih ('mahasiswa' atau 'dosen')
      String roleString = _selectedRole.name;
      final String nimNidn = nimNidnController.text.trim();
      final String namaKampus = _selectedKampus!;

      // 2. Panggil Firebase Service
      // SQF CODE: bool isSuccess = await _authDataSource.registerUser(newUser);

      await FirebaseService.registerUser(
        // <-- GANTI DENGAN FIREBASE SERVICE
        namaLengkap: namaLengkapController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: roleString,
        nimNidn: nimNidn,
        namaKampus: namaKampus,
      );

      // Stop Loading sebelum tampilkan UI Feedback
      if (!mounted) return;

      // 4. Logika Respons Sukses
      // SQF CODE: if (isSuccess) { ... }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi Berhasil! Silakan Login.'),
          backgroundColor: AppColor.kSuccessColor,
        ),
      );

      // Clear field setelah sukses
      namaLengkapController.clear();
      emailController.clear();
      passwordController.clear();
      nimNidnController.clear();

      // *Opsional: Navigasi ke tab Login jika menggunakan TabController di Authenticator
      // TabController.of(context).animateTo(0);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email ini sudah terdaftar.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah.';
      } else {
        errorMessage = 'Registrasi Gagal: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColor.kErrorColor,
        ),
      );
    } catch (e) {
      // Handle error lain (misal: Firestore error, network error, dll.)
      if (!mounted) return;

      logger.e(
        'GENERAL ERROR DURING REGISTRATION: $e',
      ); // Menggunakan logger.e() untuk ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan tak terduga.'),
          backgroundColor: AppColor.kErrorColor,
        ),
      );
    }

    // Stop Loading di finally atau setelah semua respons ditangani
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showDosenConfirmationDialog() async {
    bool isChecked = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Konfirmasi Pilihan'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Apakah Anda yakin ingin mendaftar sebagai Dosen? Pilihan ini hanya untuk Dosen/Staf Pengajar.',
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: AppColor.kPrimaryColor,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Saya mengerti dan saya adalah seorang Dosen.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: isChecked
                      ? () {
                          // Update State RegisterFormFirebase
                          setState(() {
                            _selectedRole = UserRole.dosen;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Yakin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildTextField(
                labelText: "Nama Lengkap",
                controller: namaLengkapController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              BuildTextField(
                labelText: "Email",
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final bool emailValid = RegExp(
                    r'^.+@.+\.ac\.id$',
                  ).hasMatch(value);
                  if (!emailValid) {
                    return 'Email harus menggunakan domain .ac.id';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              BuildTextField(
                labelText: "Password",
                controller: passwordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }

                  final bool hasMinimumLength = value.length >= 8;
                  final bool hasCapital = RegExp(r'[A-Z]').hasMatch(value);
                  final bool hasLowercase = RegExp(r'[a-z]').hasMatch(value);
                  final bool hasDigit = RegExp(r'[0-9]').hasMatch(value);

                  if (hasMinimumLength &&
                      hasCapital &&
                      hasLowercase &&
                      hasDigit) {
                    return null;
                  } else {
                    return 'Password harus mengandung: minimal 8 karakter, 1 huruf kapital, 1 huruf kecil, dan 1 angka.';
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedKampus,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Nama Kampus / Universitas',
                  // Warna border saat fokus menggunakan warna peran
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: AppColor.kAppBar, width: 2.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: AppColor.kDividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: AppColor.kDividerColor),
                  ),
                  filled: true,
                  fillColor: AppColor.kWhiteColor,
                  labelStyle: TextStyle(color: AppColor.kTextColor),
                ),
                hint: const Text('Pilih Kampus'),
                items: daftarKampus.map((String kampus) {
                  return DropdownMenuItem<String>(
                    value: kampus,
                    child: Text(kampus, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedKampus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kampus tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BuildTextField(
                labelText: _selectedRole == UserRole.dosen
                    ? "NIDN/NIDK"
                    : "NIM",
                controller: nimNidnController,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${_selectedRole == UserRole.dosen ? "NIDN/NIDK" : "NIM"} tidak boleh kosong'; // Wajib diisi!
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              Text(
                "Mendaftar Sebagai:",
                style: TextStyle(color: AppColor.kTextColor, fontSize: 12),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  // Tombol Mahasiswa
                  Expanded(
                    child: RoleButtonfirebase(
                      text: 'Mahasiswa',
                      icon: Icons.school,
                      role: UserRole.mahasiswa,
                      isSelected: _selectedRole == UserRole.mahasiswa,
                      onPressed: () {
                        setState(() {
                          _selectedRole = UserRole.mahasiswa;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Tombol Dosen
                  Expanded(
                    child: RoleButtonfirebase(
                      text: 'Dosen',
                      icon: Icons.person,
                      role: UserRole.dosen,
                      isSelected: _selectedRole == UserRole.dosen,
                      onPressed: () {
                        if (_selectedRole != UserRole.dosen) {
                          _showDosenConfirmationDialog();
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Tombol Daftar
              PrimaryAuthButton(
                text: 'Daftar Sekarang',
                isLoading: _isLoading,
                backgroundColor: _selectedRole == UserRole.mahasiswa
                    ? AppColor.kAccentColor
                    : AppColor.kPrimaryColor,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
