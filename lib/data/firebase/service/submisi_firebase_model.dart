// Di dalam file service ini atau file helper terpisah

import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class SubmisiDetailFirebase {
  final SubmisiFirebaseModel submisi;
  final UserFirebaseModel mahasiswa;
  // Catatan: nimNidn sudah ada di dalam UserFirebaseModel setelah di-query dari Firestore
  // Jadi, kita tidak perlu properti nim terpisah jika kita hanya menggunakan data dari model user.
  // Namun, kita pertahankan struktur ini untuk mempermudah.

  SubmisiDetailFirebase({required this.submisi, required this.mahasiswa});
}
