import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Dibutuhkan untuk memanggil provider
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_notary/features/documents/providers/document_providers.dart'; // Impor provider dokumen

class DownloadService {
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  // Metode download yang sepenuhnya baru
  Future<void> downloadFile({
    required BuildContext context,
    required WidgetRef ref, // Tambahkan ref untuk mengakses provider
    required String url,
    required String fileName,
  }) async {
    // Tampilkan loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mempersiapkan unduhan untuk $fileName...')),
    );

    try {
      // 1. Minta Izin Penyimpanan
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan diperlukan.')),
        );
        return;
      }

      // 2. Unduh byte file menggunakan Supabase SDK
      final fileBytes = await ref
          .read(documentRepositoryProvider)
          .downloadFileByUrl(url);

      // 3. Cari direktori untuk menyimpan file
      final Directory? downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir == null) {
        throw Exception('Gagal menemukan direktori penyimpanan.');
      }
      final String savePath = '${downloadsDir.path}/$fileName';

      // 4. Tulis byte ke dalam file baru
      final file = File(savePath);
      await file.writeAsBytes(fileBytes);

      print('Download selesai. File tersimpan di: $savePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName berhasil diunduh.'),
          action: SnackBarAction(
            label: 'BUKA',
            onPressed: () => OpenFile.open(savePath),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('!!! ERROR SAAT DOWNLOAD: $e');
      print('!!! STACK TRACE: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
