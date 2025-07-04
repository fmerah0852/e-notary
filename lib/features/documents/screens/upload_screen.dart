import 'dart:io';
import 'package:e_notary/features/documents/screens/upload_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_notary/features/documents/providers/document_providers.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  String? _selectedType;
  File? _pickedFile;
  bool _isLoading = false;

  final Map<String, IconData> documentTypes = {
    'Repertorium': Icons.book_outlined,
    'Akta': Icons.article_outlined,
    'Legalisasi': Icons.verified_user_outlined,
    'Waarmeking': Icons.check_box_outlined,
    'Wasiat': Icons.receipt_long_outlined,
    'Waris': Icons.groups_outlined,
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    // ... (kode pengecekan null tidak berubah) ...

    setState(() => _isLoading = true);
    try {
      await ref
          .read(documentRepositoryProvider)
          .uploadDocument(file: _pickedFile!, documentType: _selectedType!);

      // PENTING: Refresh data di provider home screen agar daftar terupdate
      // ignore: unused_result
      ref.refresh(
        documentsProvider,
      ); // Jika Anda punya provider untuk daftar dokumen

      if (mounted) {
        // Navigasi ke halaman sukses dan hapus semua halaman di atasnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UploadSuccessScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Mengunggah: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unggah Dokumen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Jenis Dokumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: documentTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                return ChoiceChip(
                  label: Text(entry.key),
                  avatar: Icon(
                    entry.value,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? entry.key : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Unggah Dokumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile == null
                          ? 'Pilih berkas'
                          : 'File: ${_pickedFile!.path.split('/').last}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  (_pickedFile == null || _selectedType == null || _isLoading)
                  ? null
                  : _uploadFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Unggah'),
            ),
          ],
        ),
      ),
    );
  }
}
