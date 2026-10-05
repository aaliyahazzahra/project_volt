import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:project_volt/app/app_router.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/core/theme/app_theme.dart';
import 'package:project_volt/firebase_options.dart';
import 'package:provider/provider.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Dibuat sekali agar sesi dan router tidak ikut dibuat ulang saat rebuild.
  final SessionController _session = SessionController();
  late final GoRouter _router = buildAppRouter(_session);

  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _session,
      child: MaterialApp.router(
        title: 'Volt',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        // Tema gelap belum dipakai; lihat spesifikasi fase 1.
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
