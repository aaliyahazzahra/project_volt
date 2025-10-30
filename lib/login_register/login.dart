import 'package:flutter/material.dart';

enum UserRole { mahasiswa, dosen } // Enum untuk menyimpan pilihan role

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  UserRole _selectedRole = UserRole.mahasiswa; // Default: mahasiswa

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: 'Nama Lengkap')),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Text(
              'Daftar Sebagai:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            // Bagian Toogle
            Row(
              children: [
                // Tombol Mahasiswa
                Expanded(
                  child: _buildRoleButton(
                    text: 'Mahasiswa',
                    icon: Icons.school,
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
                  child: _buildRoleButton(
                    text: 'Dosen',
                    icon: Icons.person,
                    isSelected: _selectedRole == UserRole.dosen,
                    onPressed: () {
                      setState(() {
                        _selectedRole = UserRole.dosen;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                print("Mendaftar sebagai: $_selectedRole");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Daftar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat tombol
  Widget _buildRoleButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    // Style berdasarkan `isSelected`
    return isSelected
        ? ElevatedButton.icon(
            // Style Tanda Terpilih (Oranye)
            icon: Icon(icon, color: Colors.white),
            label: Text(text),
            onPressed: null, // agar tidak bisa diklik lagi
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : OutlinedButton.icon(
            // Style Tanda Tidak Terpilih (Putih)
            icon: Icon(icon),
            label: Text(text),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
}
