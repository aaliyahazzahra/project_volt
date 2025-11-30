// lib/data/supabase/service/storage_supabase_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageSupabaseService {
  // Asumsikan Supabase client sudah diinisialisasi
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // GANTI DENGAN NAMA BUCKET SUPABASE ANDA
  final String _bucketName = 'submisi';

  // ===================================================
  // FUNGSI 1: MENGUNGGAH/CREATE FILE (Upload)
  // ===================================================

  /// Mengunggah file lokal ke Supabase Storage dan mengembalikan URL publiknya.
  ///
  /// [filePath] adalah path lokal dari file yang diunggah.
  /// [fileName] adalah nama file yang unik.
  /// [folderPath] adalah folder di dalam bucket (misal: 'tugas/kelas_abc').
  ///
  /// Mengembalikan: Public URL dari file yang diunggah.
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String folderPath,
  }) async {
    final file = File(filePath);
    final destinationPath = '$folderPath/$fileName';

    try {
      // Menggunakan method .upload() dan mengatur upsert: true
      // (meskipun kita fokus pada CREATE, upsert=true memungkinkan
      // penimpaan file jika nama file sama, yang berguna untuk penanganan error)
      await _supabaseClient.storage
          .from(_bucketName)
          .upload(
            destinationPath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Mengizinkan penimpaan jika nama file sama
            ),
          );

      // Dapatkan URL publik dari file yang baru diunggah
      final String publicUrl = _supabaseClient.storage
          .from(_bucketName)
          .getPublicUrl(destinationPath);

      return publicUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error (${e.statusCode}): ${e.message}');
      throw Exception('Gagal mengunggah file. Error: ${e.message}');
    } catch (e) {
      print('General Upload Error: $e');
      throw Exception('Terjadi kesalahan umum saat mengunggah file.');
    }
  }

  // ===================================================
  // FUNGSI 2: MENGHAPUS FILE (Delete)
  // ===================================================

  /// Menghapus file dari Supabase Storage berdasarkan URL publiknya.
  ///
  /// [publicUrl] adalah URL lengkap dari file yang ingin dihapus.
  ///
  /// Mengembalikan: void (melempar Exception jika gagal).
  Future<void> deleteFile({required String publicUrl}) async {
    // 1. Ekstrak path/lokasi file dari URL publik
    // Contoh URL: https://supabase-url.com/storage/v1/object/public/submission_files/tugas/abc/file.pdf
    final uri = Uri.parse(publicUrl);

    // Path yang dibutuhkan Supabase hanya bagian setelah nama bucket
    // Contoh: 'tugas/abc/file.pdf'
    final String pathInStorage = uri.path
        .split('object/public/$_bucketName/')
        .last;

    try {
      await _supabaseClient.storage.from(_bucketName).remove([pathInStorage]);
    } on StorageException catch (e) {
      print('Supabase Storage Delete Error (${e.statusCode}): ${e.message}');
      // Jangan throw error jika file tidak ditemukan (404), anggap saja sukses dihapus
      if (e.statusCode != '404') {
        throw Exception('Gagal menghapus file. Error: ${e.message}');
      }
    } catch (e) {
      print('General Delete Error: $e');
      throw Exception('Terjadi kesalahan umum saat menghapus file.');
    }
  }
}
