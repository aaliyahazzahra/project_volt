// file: TugasSubmissionFirebasePage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
// Import untuk url_launcher (diperlukan untuk fungsi _launchUrl)
import 'package:url_launcher/url_launcher.dart';

import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
import 'package:project_volt/data/firebase/service/storage_supabase_service.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Asumsi widget BuildTextField sudah ada di path ini

class TugasSubmissionFirebasePage extends StatefulWidget {
  final TugasFirebaseModel tugas;
  final UserFirebaseModel user;

  const TugasSubmissionFirebasePage({
    super.key,
    required this.tugas,
    required this.user,
  });

  @override
  State<TugasSubmissionFirebasePage> createState() =>
      _TugasSubmissionFirebasePageState();
}

class _TugasSubmissionFirebasePageState
    extends State<TugasSubmissionFirebasePage> {
  // SERVICES
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();
  final StorageSupabaseService _storageService = StorageSupabaseService();

  // STATE UTAMA
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSimulasiAttached = false;
  bool _isDeadlinePassed = false; // NEW: State untuk deadline

  // STATE DATA SUBMISI (Yang sudah tersimpan di database)
  SubmisiFirebaseModel? _currentSubmisi;
  String? _submittedSimulasiId;
  String? _submittedFilePath;
  // String? _submittedTextAnswer; // Seharusnya diambil dari _currentSubmisi?.textSubmisi

  // STATE DRAFT (Yang baru dipilih tapi BELUM dikirim)
  PlatformFile? _unsavedFile;
  String? _unsavedSimulasiId;
  String? _unsavedTextAnswer; // NEW: Draft untuk teks jawaban
  final TextEditingController _textController =
      TextEditingController(); // Controller input teks

  // Tentukan warna tema Mahasiswa
  final Color _themeColor = AppColor.kAccentColor;
  final Color _draftFileColor = AppColor
      .kPrimaryColor; // NEW: Warna yang lebih tenang untuk draft (Ganti dari kWarningColor)

  @override
  void initState() {
    super.initState();
    // Cek apakah dosen melampirkan template
    _isSimulasiAttached = widget.tugas.simulasiId != null;

    // NEW: Cek Deadline
    if (widget.tugas.tglTenggat != null) {
      _isDeadlinePassed = widget.tugas.tglTenggat!.isBefore(DateTime.now());
    }

    _loadCurrentSubmisi();

    // Isi controller jika sudah ada submisi teks sebelumnya
    _textController.text = _currentSubmisi?.textSubmisi ?? '';

    // Listener untuk draft teks
    _textController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChange);
    _textController.dispose();
    super.dispose();
  }

  // Helper untuk menyimpan perubahan teks
  void _onTextChange() {
    setState(() {
      // Simpan perubahan teks ke draft saat pengguna mengetik (optional, tapi bagus untuk UX)
      _unsavedTextAnswer = _textController.text.trim().isNotEmpty
          ? _textController.text.trim()
          : null;
    });
  }

  // Helper untuk membuka URL (butuh package url_launcher)
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        _showSnackbar(
          'Gagal membuka tautan. Pastikan URL valid.',
          ContentType.failure,
        );
      }
    }
  }

  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Peringatan",
      message: message.replaceAll('Error: ', '').replaceAll('Exception: ', ''),
      contentType: type,
    );

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: snackBarContent,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // --- 1. LOAD DATA ---
  Future<void> _loadCurrentSubmisi() async {
    if (widget.tugas.tugasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final submisi = await _submisiService.getSubmisiByTugasAndMahasiswa(
        widget.tugas.tugasId!,
        widget.user.uid,
      );

      if (mounted) {
        setState(() {
          _currentSubmisi = submisi;
          _submittedSimulasiId = submisi?.simulasiSubmisiId;
          _submittedFilePath = submisi?.filePathSubmisi;
          // Isi controller jika sudah ada submisi teks sebelumnya
          if (submisi?.textSubmisi != null &&
              submisi!.textSubmisi!.isNotEmpty) {
            _textController.text = submisi.textSubmisi!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading submission: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. LOGIKA PICK FILE (Hanya memilih, tidak upload) ---
  void _pickFile() async {
    if (_isSubmitting) return;

    // Reset draft lain saat memilih file
    setState(() {
      _unsavedSimulasiId = null;
      _textController.clear();
      _unsavedTextAnswer = null;
    });

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
      );
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          'Gagal memilih file: ${e.toString()}',
          ContentType.failure,
        );
      }
      return;
    }

    if (result != null && result.files.single.path != null) {
      // Simpan file ke variabel sementara (_unsavedFile)
      setState(() {
        _unsavedFile = result!.files.single;
      });
    }
  }

  // Navigasi simulasi
  void _navigateToSimulationWorkspace({String? loadSimulasiId}) async {
    if (_isSubmitting) return;

    // Reset draft lain saat masuk workspace simulasi
    setState(() {
      _unsavedFile = null;
      _textController.clear();
      _unsavedTextAnswer = null;
    });

    // Navigasi ke Editor Simulasi
    final String? resultSimulasiId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSimulasiFirebasePage(
          kelasId: widget.tugas.kelasId,
          user: widget.user,
          // Menggunakan ID template Dosen atau ID submisi Mahasiswa
          loadSimulasiId: loadSimulasiId,
        ),
      ),
    );

    // Jika user kembali membawa ID Simulasi baru
    if (resultSimulasiId != null && mounted) {
      setState(() {
        _unsavedSimulasiId = resultSimulasiId; // Simpan sebagai DRAFT
      });
    }
  }

  // --- 3. LOGIKA FINAL: UPLOAD & SUBMIT FILE/SIMULASI ---
  void _uploadAndSubmitFile() async {
    // Pastikan ada draft file atau simulasi
    if (_unsavedFile == null && _unsavedSimulasiId == null) {
      _showSnackbar(
        "Harap pilih file atau kerjakan simulasi terlebih dahulu.",
        ContentType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? storageUrl;
    String? finalSimulasiId = _unsavedSimulasiId;

    try {
      // A. JIKA MENGIRIM FILE -> Upload ke Supabase dulu
      if (_unsavedFile != null) {
        final filePath = _unsavedFile!.path!;
        final String uniqueFileName =
            '${widget.user.uid}_${widget.tugas.tugasId}_${DateTime.now().millisecondsSinceEpoch}_${_unsavedFile!.name}';
        final String folderPath = 'tugas/${widget.tugas.kelasId}';

        // Hapus file lama jika ada (dan HAPUS SUBMISI TEKS LAMA)
        if (_currentSubmisi?.filePathSubmisi != null) {
          _storageService
              .deleteFile(publicUrl: _currentSubmisi!.filePathSubmisi!)
              .catchError((e) => print("Info: Gagal hapus file lama: $e"));
        }

        // Upload File Baru
        storageUrl = await _storageService.uploadFile(
          filePath: filePath,
          fileName: uniqueFileName,
          folderPath: folderPath,
        );

        if (storageUrl == null) throw Exception("Gagal mendapatkan URL file.");
      }

      // B. SIMPAN DATA KE FIRESTORE (File atau Simulasi)
      await _submitSubmisiToFirestore(
        filePath: storageUrl,
        simulasiId: finalSimulasiId,
        textAnswer: null, // Kosongkan teks jika submit file/simulasi
        status: 'DISUBMIT',
      );
    } catch (e) {
      print("Error Upload/Submit: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackbar(
          'Gagal mengirim tugas: ${e.toString()}',
          ContentType.failure,
        );
      }
    }
  }

  // --- 4. LOGIKA FINAL: SUBMIT TEKS JAWABAN (NEW) ---
  void _uploadAndSubmitText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackbar(
        "Kotak jawaban teks tidak boleh kosong.",
        ContentType.warning,
      );
      return;
    }

    // Reset draft lainnya saat submit teks
    setState(() {
      _isSubmitting = true;
      _unsavedFile = null;
      _unsavedSimulasiId = null;
      _unsavedTextAnswer = text; // Simpan teks dari controller
    });

    try {
      // Hapus file lama jika ada
      if (_currentSubmisi?.filePathSubmisi != null) {
        _storageService
            .deleteFile(publicUrl: _currentSubmisi!.filePathSubmisi!)
            .catchError((e) => print("Info: Gagal hapus file lama: $e"));
      }

      // B. SIMPAN DATA KE FIRESTORE
      await _submitSubmisiToFirestore(
        filePath: null,
        simulasiId: null,
        textAnswer: _unsavedTextAnswer,
        status: 'DISUBMIT',
      );
    } catch (e) {
      print("Error Submit Teks: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackbar(
          'Gagal mengirim tugas teks: ${e.toString()}',
          ContentType.failure,
        );
      }
    }
  }

  // Fungsi helper untuk menulis ke Firestore
  Future<void> _submitSubmisiToFirestore({
    String? filePath,
    String? simulasiId,
    String? textAnswer, // NEW PARAMETER
    required String status,
  }) async {
    if (widget.tugas.tugasId == null) return;

    final submisiToSave = _currentSubmisi != null
        ? _currentSubmisi!.copyWith(
            simulasiSubmisiId: simulasiId,
            filePathSubmisi: filePath,
            textSubmisi: textAnswer, // SAVE TEXT
            tglSubmit: DateTime.now(),
            status: status,
          )
        : SubmisiFirebaseModel(
            tugasId: widget.tugas.tugasId!,
            mahasiswaId: widget.user.uid,
            tglSubmit: DateTime.now(),
            filePathSubmisi: filePath,
            simulasiSubmisiId: simulasiId,
            textSubmisi: textAnswer, // SAVE TEXT
            status: status,
          );

    await _submisiService.createOrUpdateSubmisi(submisiToSave);

    if (mounted) {
      _showSnackbar(
        'Tugas berhasil disubmit! Status: $status',
        ContentType.success,
      );

      // Reset State Draft dan Controller
      setState(() {
        _unsavedFile = null;
        _unsavedSimulasiId = null;
        _unsavedTextAnswer = null;
        _isSubmitting = false;
        // _textController.clear(); // Jangan clear controller, biarkan teks tetap ada untuk diedit
      });
      // Refresh Data & Keluar
      _loadCurrentSubmisi();
      Navigator.pop(context, true);
    }
  }

  // --- 5. UI WIDGETS ---

  // NEW: Dialog untuk Teks Lengkap
  void _showTextDetailDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Jawaban Teks Lengkap",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.kTextColor,
          ),
        ),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: TextStyle(color: _themeColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionButton() {
    // Tombol tidak aktif jika deadline sudah lewat
    if (_isDeadlinePassed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.kErrorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.kErrorColor),
        ),
        child: const Text(
          "⚠️ Tenggat waktu pengumpulan tugas telah berakhir. Tugas tidak dapat lagi dikirim.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColor.kErrorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // A. JIKA ADA DRAFT SIMULASI (Belum dikirim)
    if (_unsavedSimulasiId != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _themeColor.withOpacity(0.1),
              border: Border.all(color: _themeColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.electrical_services, color: _themeColor),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Simulasi selesai dikerjakan. Siap dikirim.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColor.kErrorColor),
                  onPressed: () => setState(() => _unsavedSimulasiId = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _uploadAndSubmitFile,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.kWhiteColor,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              _isSubmitting ? "Mengirim..." : "Konfirmasi & Kirim Simulasi",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kSuccessColor,
              foregroundColor: AppColor.kWhiteColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    }

    // B. JIKA ADA DRAFT FILE (Belum dikirim)
    if (_unsavedFile != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // NEW COLOR: Menggunakan kPrimaryColor/Orange yang lebih lembut untuk Draft File
              color: _draftFileColor.withOpacity(0.1),
              border: Border.all(color: _draftFileColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.description, color: _draftFileColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Draft File: ${_unsavedFile!.name}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColor.kErrorColor),
                  onPressed: () => setState(() => _unsavedFile = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _uploadAndSubmitFile,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.kWhiteColor,
                    ),
                  )
                : const Icon(Icons.upload_file),
            label: Text(
              _isSubmitting ? "Mengunggah..." : "Konfirmasi & Kirim File",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kSuccessColor,
              foregroundColor: AppColor.kWhiteColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    }

    // C. TAMPILAN STANDAR (Belum ada draft) - Tombol Opsi

    // Tombol 1: File Upload
    final fileUploadButton = ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _pickFile,
      icon: const Icon(Icons.upload_file),
      label: Text(
        _submittedFilePath != null
            ? 'Ganti File Submisi'
            : 'Pilih File Jawaban (PDF/ZIP/DOCX)',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeColor,
        foregroundColor: AppColor.kWhiteColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
    );

    // Tombol 2: Simulasi (Template Dosen ATAU Kustom)
    final simLabel = _isSimulasiAttached
        ? (_submittedSimulasiId != null
              ? 'Ulangi Kerjakan (Template Dosen)'
              : 'Kerjakan Simulasi (Template Dosen)')
        : (_submittedSimulasiId != null
              ? 'Edit Simulasi Kustom'
              : 'Buat Simulasi Kustom (Dari Nol)');

    final simulasiButton = OutlinedButton.icon(
      onPressed: _isSubmitting
          ? null
          : () => _navigateToSimulationWorkspace(
              // Jika sudah ada submisi simulasi, muat submisi tersebut
              loadSimulasiId: _submittedSimulasiId ?? widget.tugas.simulasiId,
            ),
      icon: const Icon(Icons.settings_input_component),
      label: Text(simLabel),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        foregroundColor: AppColor
            .kPrimaryColor, // Gunakan Primary/Orange agar kontras dengan File/Biru
        side: const BorderSide(color: AppColor.kPrimaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Column(
      children: [fileUploadButton, const SizedBox(height: 10), simulasiButton],
    );
  }

  // NEW WIDGET: Area Input Teks Jawaban (Hanya tampil jika tidak ada draft lain)
  Widget _buildTextInputField() {
    // Tampilkan hanya jika tidak ada draft file atau simulasi yang aktif
    if (_unsavedFile != null ||
        _unsavedSimulasiId != null ||
        _isDeadlinePassed) {
      return const SizedBox.shrink();
    }

    final bool hasExistingText =
        _currentSubmisi?.textSubmisi != null &&
        _currentSubmisi!.textSubmisi!.isNotEmpty;

    // Teks header
    final String label = hasExistingText
        ? "Revisi Jawaban Teks (Jawaban Sebelumnya Tersimpan)"
        : "Jawaban Teks Langsung (Jawaban Singkat/Link)";

    final String buttonLabel = hasExistingText
        ? "Perbarui Jawaban Teks"
        : "Kirim Jawaban Teks";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          "Atau Gunakan Jawaban Teks:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextSecondaryColor,
          ),
        ),
        const Divider(height: 15, color: AppColor.kDividerColor),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        // MENGGUNAKAN WIDGET BuildTextField
        BuildTextField(
          controller: _textController,
          labelText: "Masukkan Jawaban Teks atau Link di sini...",
          maxLines: 5,
          labelColor: AppColor.kTextSecondaryColor,
        ),
        const SizedBox(height: 15),
        // Tombol khusus untuk mengirim teks
        if (_textController.text.trim().isNotEmpty)
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _uploadAndSubmitText,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.kWhiteColor,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_isSubmitting ? "Mengirim Teks..." : buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kPrimaryColor,
              foregroundColor: AppColor.kWhiteColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTugasInfo() {
    final String tenggatFormatted = widget.tugas.tglTenggat != null
        ? DateFormat('EEEE, dd MMM yyyy HH:mm').format(widget.tugas.tglTenggat!)
        : 'Tidak ada tenggat waktu';

    final bool isDueSoon =
        widget.tugas.tglTenggat != null &&
        widget.tugas.tglTenggat!.difference(DateTime.now()).inHours < 24 &&
        !_isDeadlinePassed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.tugas.judul,
          style: const TextStyle(
            fontSize: 24, // Dibuat lebih besar
            fontWeight: FontWeight.bold,
            color: AppColor.kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _isDeadlinePassed ? Icons.alarm_off : Icons.schedule,
              size: 16,
              color: _isDeadlinePassed
                  ? AppColor.kErrorColor
                  : (isDueSoon
                        ? AppColor.kWarningColor
                        : AppColor.kTextSecondaryColor),
            ),
            const SizedBox(width: 5),
            Text(
              "Tenggat: $tenggatFormatted",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: _isDeadlinePassed
                    ? AppColor.kErrorColor
                    : (isDueSoon
                          ? AppColor.kWarningColor
                          : AppColor.kTextSecondaryColor),
                fontWeight: isDueSoon || _isDeadlinePassed
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (isDueSoon)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Chip(
                  label: const Text("Segera berakhir!"),
                  backgroundColor: AppColor.kWarningColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: AppColor.kWarningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        const Divider(height: 25, color: AppColor.kDividerColor),
        Text(
          "Instruksi Tugas:",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.tugas.deskripsi ?? "Tidak ada deskripsi/instruksi.",
          style: const TextStyle(
            fontSize: 16,
            color: AppColor.kTextSecondaryColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSubmisiStatusContent() {
    // Helper function untuk menentukan warna status Submisi
    Color _getStatusColor(String status) {
      if (status == 'DISUBMIT') return AppColor.kSuccessColor;
      if (status == 'DINILAI')
        return AppColor.kPrimaryColor; // Menggunakan Orange untuk status nilai
      return AppColor.kErrorColor;
    }

    if (_currentSubmisi == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.kLightAccentColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: _themeColor),
            const SizedBox(width: 10),
            const Text(
              "Anda belum mengirimkan tugas ini.",
              style: TextStyle(
                color: AppColor.kTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Warna untuk status DISUBMIT
    final statusColor = _getStatusColor(_currentSubmisi!.status);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            _currentSubmisi!.status == 'DISUBMIT'
                ? Icons.done_all
                : (_currentSubmisi!.status == 'DINILAI'
                      ? Icons.grade
                      : Icons.warning_amber),
            color: statusColor,
            size: 30,
          ),
          title: Text(
            "Status Submisi: ${_currentSubmisi!.status}",
            style: const TextStyle(
              color: AppColor.kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "Dikirim pada: ${DateFormat('dd MMM HH:mm').format(_currentSubmisi!.tglSubmit!)}",
            style: const TextStyle(color: AppColor.kTextSecondaryColor),
          ),
          trailing: _currentSubmisi!.nilai != null
              ? Chip(
                  label: Text("Nilai: ${_currentSubmisi!.nilai}"),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSubmittedHistory() {
    // Tampilkan hanya jika ada submisi yang sudah terkirim
    if (_currentSubmisi == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Riwayat ---
        const SizedBox(height: 10),
        const Text(
          "Riwayat Pengumpulan Sebelumnya",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextColor,
          ),
        ),
        const Divider(color: AppColor.kDividerColor),

        // --- Detail File/Simulasi/Teks yang SUDAH Terkirim (History) ---

        // 1. Riwayat File
        if (_submittedFilePath != null)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            color: AppColor.kWhiteColor,
            child: ListTile(
              title: const Text(
                "File Terkirim",
                style: TextStyle(
                  color: AppColor.kTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _submittedFilePath!.split('/').last,
                style: const TextStyle(color: AppColor.kTextSecondaryColor),
              ),
              leading: const Icon(
                Icons.attach_file,
                color: AppColor.kAccentColor,
              ),
              // NEW: Tombol Unduh
              trailing: IconButton(
                icon: const Icon(
                  Icons.download,
                  color:
                      AppColor.kSuccessColor, // Hijau untuk aksi sukses (unduh)
                ),
                onPressed: () => _launchUrl(_submittedFilePath!),
                tooltip: 'Lihat/Unduh File',
              ),
            ),
          ),

        // 2. Riwayat Simulasi
        if (_submittedSimulasiId != null)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            color: AppColor.kWhiteColor,
            child: ListTile(
              title: const Text(
                "Proyek Simulasi Terkirim",
                style: TextStyle(
                  color: AppColor.kTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                "Data simulasi tersimpan di server.",
                style: TextStyle(color: AppColor.kTextSecondaryColor),
              ),
              leading: const Icon(
                Icons.settings_input_component,
                color: AppColor.kAccentColor,
              ),
              // NEW: Tombol Edit/Lihat
              trailing: IconButton(
                icon: const Icon(
                  Icons.visibility,
                  color: AppColor
                      .kPrimaryColor, // Orange untuk aksi terkait Simulasi
                ),
                onPressed: () => _navigateToSimulationWorkspace(
                  loadSimulasiId: _submittedSimulasiId,
                ),
                tooltip: 'Edit/Lihat Simulasi',
              ),
            ),
          ),

        // 3. Riwayat Jawaban Teks
        if (_currentSubmisi?.textSubmisi != null &&
            _currentSubmisi!.textSubmisi!.isNotEmpty)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            color: AppColor.kWhiteColor,
            child: ListTile(
              title: const Text(
                "Jawaban Teks Terkirim",
                style: TextStyle(
                  color: AppColor.kTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _currentSubmisi!.textSubmisi!.length > 50
                    ? "${_currentSubmisi!.textSubmisi!.substring(0, 50)}..."
                    : _currentSubmisi!.textSubmisi!,
                style: const TextStyle(color: AppColor.kTextSecondaryColor),
              ),
              leading: const Icon(
                Icons.short_text,
                color: AppColor.kPrimaryColor,
              ),
              // NEW: Tombol Lihat Teks Lengkap
              trailing: IconButton(
                icon: const Icon(
                  Icons.description,
                  color: AppColor.kPrimaryColor,
                ),
                onPressed: () {
                  _showTextDetailDialog(_currentSubmisi!.textSubmisi!);
                },
                tooltip: 'Lihat Jawaban Teks Lengkap',
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor
          .kBackgroundColorMhs, // Ganti ke warna latar belakang mahasiswa
      appBar: AppBar(
        title: const Text(
          "Pengumpulan Tugas", // Dibuat lebih generik
          style: TextStyle(
            color: AppColor.kWhiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Tema Biru Mahasiswa
        backgroundColor: AppColor.kAccentColor,
        foregroundColor: AppColor.kWhiteColor,
        elevation: 0, // Tampilan modern sering tanpa elevation
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _themeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(
                18.0,
              ), // Padding sedikit lebih besar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Info Tugas ---
                  _buildTugasInfo(),

                  // --- Header Status & Status Submisi Saat Ini ---
                  const Text(
                    "Status dan Aksi Pengumpulan",
                    style: TextStyle(
                      fontSize: 20, // Lebih besar
                      fontWeight: FontWeight.bold,
                      color: AppColor.kTextColor,
                    ),
                  ),
                  const Divider(color: AppColor.kDividerColor),
                  _buildSubmisiStatusContent(),
                  const SizedBox(height: 15),

                  // --- Tombol Aksi (Dinamis sesuai state) ---
                  _buildSubmissionButton(),

                  // --- Area Input Teks BARU ---
                  _buildTextInputField(),

                  const SizedBox(height: 30),

                  // --- Detail File/Simulasi/Teks yang SUDAH Terkirim (History) ---
                  _buildSubmittedHistory(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}
