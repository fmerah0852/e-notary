import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_notary/features/documents/models/document_model.dart';
import 'package:e_notary/features/documents/providers/document_providers.dart';
import 'package:intl/intl.dart'; // Impor untuk format tanggal

// State untuk menyimpan filter pencarian
final searchFilterProvider = StateProvider<Map<String, String>>(
  (ref) => {'name': '', 'type': ''},
);

// Provider untuk menjalankan pencarian secara dinamis
final searchedDocumentsProvider = FutureProvider<List<Document>>((ref) {
  final filters = ref.watch(searchFilterProvider);
  final docRepo = ref.watch(documentRepositoryProvider);

  return docRepo.searchDocuments(
    name: filters['name'],
    documentType: filters['type'],
  );
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(searchedDocumentsProvider);
    final searchFilter = ref.watch(searchFilterProvider);

    // SAMAKAN DAFTAR INI DENGAN YANG ADA DI UPLOAD_SCREEN.DART
    final Map<String, IconData> documentTypes = {
      'Repertorium': Icons.book_outlined,
      'Akta': Icons.article_outlined,
      'Legalisasi': Icons.verified_user_outlined,
      'Waarmeking': Icons.check_box_outlined,
      'Wasiat': Icons.receipt_long_outlined,
      'Waris': Icons.groups_outlined,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Dokumen'),
        backgroundColor: const Color(0xFF1B3A6A), // Menyamakan warna AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Nama
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama file...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              onChanged: (value) {
                ref
                    .read(searchFilterProvider.notifier)
                    .update((state) => {...state, 'name': value});
              },
            ),
            const SizedBox(height: 20),

            // Filter Jenis Dokumen
            Text(
              "Pilih Jenis Dokumen",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: documentTypes.entries.map((entry) {
                final isSelected = searchFilter['type'] == entry.key;
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
                    ref
                        .read(searchFilterProvider.notifier)
                        .update(
                          (state) => {
                            ...state,
                            'type': selected ? entry.key : '',
                          },
                        );
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32, thickness: 1),

            // Hasil Pencarian
            Expanded(
              child: searchResult.when(
                data: (documents) {
                  if (documents.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.find_in_page_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada dokumen ditemukan.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'Coba ubah kata kunci pencarian Anda.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Icon(
                              documentTypes[doc.documentType] ??
                                  Icons.insert_drive_file,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            doc.fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Jenis: ${doc.documentType}\nDiunggah: ${DateFormat('dd MMMM yyyy').format(doc.createdAt)}',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Aksi ketika item di-tap, misal membuka dokumen
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Terjadi kesalahan: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
