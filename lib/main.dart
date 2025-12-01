import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_volt/features/0_splash/Firebase/splash_screen_firebase.dart';
import 'package:project_volt/firebase_options.dart';
// Impor Supabase yang baru ditambahkan
import 'package:supabase_flutter/supabase_flutter.dart';

// Kredensial Supabase
const String supabaseUrl = 'https://fxsskhupmqzzlhsktaqv.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4c3NraHVwbXF6emxoc2t0YXF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwOTMyMTYsImV4cCI6MjA3OTY2OTIxNn0.itbDsTbdFVPB4yMpBvzupWKfvRx-LSdBUnzcTYEnZ6M';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi format tanggal (intl)
  await initializeDateFormatting('id_ID', null);

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inisialisasi Supabase (DITAMBAHKAN)
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
