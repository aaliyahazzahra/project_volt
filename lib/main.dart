import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_volt/features/0_splash/Firebase/splash_screen_firebase.dart';
import 'package:project_volt/firebase_options.dart';
// Impor Supabase yang baru ditambahkan
import 'package:supabase_flutter/supabase_flutter.dart';

// Kredensial Supabase, diisi lewat --dart-define-from-file=config/supabase.json
// (lihat config/supabase.example.json dan README)
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi format tanggal (intl)
  await initializeDateFormatting('id_ID', null);

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inisialisasi Supabase
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY kosong. Jalankan dengan '
      '--dart-define-from-file=config/supabase.json',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreenFirebase(),
    );
  }
}
