import 'dart:io';
import 'dart:typed_data'; // Pastikan import ini ada
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_notary/features/documents/models/document_model.dart';

class DocumentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Document>> fetchDocuments() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    try {
      final data = await _client
          .from('documents')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return data.map((item) => Document.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  Future<List<Document>> searchDocuments({
    String? name,
    String? documentType,
    DateTime? startDate, // Tambahkan parameter ini
    DateTime? endDate, // Tambahkan parameter ini
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      var query = _client.from('documents').select().eq('user_id', user.id);

      // Filter berdasarkan nama (case-insensitive)
      if (name != null && name.isNotEmpty) {
        query = query.ilike('file_name', '%$name%');
      }

      // Filter berdasarkan jenis dokumen (WAJIB ADA)
      if (documentType != null && documentType.isNotEmpty) {
        query = query.eq('document_type', documentType);
      }

      // Filter berdasarkan rentang tanggal
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        // Tambahkan 1 hari ke endDate agar pencarian mencakup seluruh hari tersebut
        query = query.lte(
          'created_at',
          endDate.add(const Duration(days: 1)).toIso8601String(),
        );
      }

      final data = await query.order('created_at', ascending: false);
      return data.map((item) => Document.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Gagal mencari dokumen: $e');
    }
  }

  // --- TAMBAHKAN METODE BARU INI ---
  Future<Uint8List> downloadFileByUrl(String fileUrl) async {
    // Ekstrak path file dari URL lengkap
    final uri = Uri.parse(fileUrl);

    // UBAH DARI sublist(4) MENJADI sublist(5)
    final path = uri.pathSegments.sublist(5).join('/');
    print("DEBUG: Extracted path for download: $path"); // Tambahan debug

    try {
      final Uint8List fileBytes = await _client.storage
          .from('documents')
          .download(path);
      return fileBytes;
    } catch (e) {
      print("Error download dari Supabase Storage: $e");
      throw Exception('Gagal mengunduh file dari server.');
    }
  }

  // Tambahkan fungsi upload, delete, dll di sini
  Future<void> uploadDocument({
    required File file,
    required String documentType,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileName = p.basename(file.path);
    final uploadPath = '${user.id}/$fileName';

    await _client.storage.from('documents').upload(uploadPath, file);
    final fileUrl = _client.storage.from('documents').getPublicUrl(uploadPath);

    await _client.from('documents').insert({
      'user_id': user.id,
      'file_name': fileName,
      'file_url': fileUrl,
      'document_type': documentType, // Gunakan jenis dari parameter
    });
  }
}
