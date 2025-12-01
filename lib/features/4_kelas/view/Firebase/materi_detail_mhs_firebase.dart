// lib/features//view/Firebase/materi_detail_mhs_firebase.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/simulasi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart';
import 'package:project_volt/data/firebase/service/simulasi_firebase_service.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
import 'package:project_volt/widgets/emptystate.dart';

class MateriDetailMhsFirebase extends StatefulWidget {
  final String materiId;
  final UserFirebaseModel user;

  const MateriDetailMhsFirebase({
    super.key,
    required this.materiId,
    required this.user,
  });

  @override
  State<MateriDetailMhsFirebase> createState() =>
      _MateriDetailMhsFirebaseState();
}

class _MateriDetailMhsFirebaseState extends State<MateriDetailMhsFirebase> {
  final MateriFirebaseService _materiService = MateriFirebaseService();
  final SimulasiFirebaseService _simulasiService = SimulasiFirebaseService();

  // State untuk data Materi
  MateriFirebaseModel? _materi;
  SimulasiFirebaseModel? _simulasiMateri;

  late bool _isDosen;

  /// Determines the scaffold background color based on user role.
  Color get _scaffoldBgColor =>
      _isDosen ? AppColor.kBackgroundColor : AppColor.kBackgroundColorMhs;

  /// Determines the appbar background color based on user role.
  Color get _appBarColor => _isDosen ? AppColor.kAppBar : AppColor.kAccentColor;

  /// Determines the appbar title color based on user role.
  Color get _appBarTitleColor =>
      _isDosen ? AppColor.kTextColor : AppColor.kWhiteColor;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateriData();
  }

  // --- LOGIC LOADING DATA ---

  Future<void> _loadMateriData() async {
    try {
      final materiData = await _materiService.getMateriById(widget.materiId);

      if (materiData != null && mounted) {
        setState(() {
          _materi = materiData;
          _isLoading = false;
        });

        if (_materi!.simulasiId != null) {
          _loadSimulasiLampiran(_materi!.simulasiId!);
        }
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          "Error",
          "Gagal memuat materi: ${e.toString()}",
          ContentType.failure,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSimulasiLampiran(String simulasiId) async {
    try {
      final simulasiData = await _simulasiService.getSimulasiById(simulasiId);
      if (mounted && simulasiData != null) {
        setState(() {
          _simulasiMateri = simulasiData;
        });
      }
    } catch (e) {
      _showSnackbar(
        "Error",
        "Gagal memuat proyek simulasi lampiran: ${e.toString()}",
        ContentType.failure,
      );
    }
  }

  // --- LOGIC NAVIGATION ---

  void _viewSimulasiMateri() {
    if (_materi == null || _simulasiMateri == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSimulasiFirebasePage(
          kelasId: _materi!.kelasId,
          user: widget.user,
          loadSimulasiId: _simulasiMateri!.simulasiId,
          isReadOnly: true,
        ),
      ),
    );
  }

  // --- UTILITY ---

  void _showSnackbar(String title, String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: snackBarContent,
      ),
    );
  }

  // --- WIDGET BUILDER ---

  Widget _buildLampiranSimulasi() {
    if (_materi?.simulasiId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lampiran Proyek Simulasi:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          color: AppColor.kLightAccentColor,
          child: ListTile(
            leading: const Icon(
              Icons.developer_board,
              color: AppColor.kPrimaryColor,
            ),
            title: Text(
              _simulasiMateri == null
                  ? "Memuat Proyek..."
                  : _simulasiMateri!.judul,
            ),
            subtitle: const Text("Tinjau sirkuit yang telah dibuat Dosen."),
            trailing: _simulasiMateri != null
                ? const Icon(Icons.arrow_forward_ios)
                : null,
            onTap: _simulasiMateri != null ? _viewSimulasiMateri : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Materi")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_materi == null) {
      return Scaffold(
        backgroundColor: _scaffoldBgColor,

        appBar: AppBar(
          title: Text(
            "Detail Materi",
            style: TextStyle(
              color: _appBarTitleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: _appBarColor,
        ),
        body: const EmptyStateWidget(
          imagePath: AppImages.materimhs,
          // icon: Icons.search_off,
          title: "Materi Tidak Ditemukan",
          message: "Mungkin materi ini sudah dihapus oleh Dosen.",
        ),
      );
    }

    // 1. Ambil String dari model
    final String tglPostingString = _materi!.tglPosting;
    // 2. Parse String ke DateTime
    final DateTime? parsedDate = DateTime.tryParse(tglPostingString);
    // 3. Format hasil parse (ini adalah variabel yang digunakan di UI)
    final String tglPostingFormatted = parsedDate != null
        ? DateFormat('dd MMM yyyy HH:mm').format(parsedDate)
        : 'Tanggal tidak diketahui';

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(_materi!.judul),
        backgroundColor: AppColor.kPrimaryColor,
        foregroundColor: AppColor.kWhiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _materi!.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dibuat pada: $tglPostingFormatted",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const Divider(height: 30),

            const Text(
              "Konten Materi:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _materi!.deskripsi ?? "(Tidak ada deskripsi konten dari Dosen.)",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 30),

            _buildLampiranSimulasi(),
          ],
        ),
      ),
    );
  }
}
