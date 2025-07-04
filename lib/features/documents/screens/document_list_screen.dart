import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_notary/features/documents/models/document_model.dart';
import 'package:e_notary/features/documents/providers/document_providers.dart';
import 'package:e_notary/core/services/download_service.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart';

// --- Provider (tidak ada perubahan) ---
final documentListFilterProvider =
    StateProvider.autoDispose<Map<String, dynamic>>((ref) {
      return {'name': '', 'startDate': null, 'endDate': null};
    });

final filteredDocumentsProvider = FutureProvider.autoDispose
    .family<List<Document>, String>((ref, documentType) {
      final filters = ref.watch(documentListFilterProvider);
      final docRepo = ref.watch(documentRepositoryProvider);

      return docRepo.searchDocuments(
        documentType: documentType,
        name: filters['name'],
        startDate: filters['startDate'],
        endDate: filters['endDate'],
      );
    });

// --- Widget (diubah menjadi ConsumerStatefulWidget) ---
class DocumentListScreen extends ConsumerStatefulWidget {
  final String documentType;
  const DocumentListScreen({super.key, required this.documentType});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  // Inisialisasi DownloadService di dalam State
  final DownloadService _downloadService = DownloadService();

  Future<void> _selectDateRange(BuildContext context) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (dateRange != null) {
      ref.read(documentListFilterProvider.notifier).update((state) {
        return {
          ...state,
          'startDate': dateRange.start,
          'endDate': dateRange.end,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsProvider = ref.watch(
      filteredDocumentsProvider(widget.documentType),
    );
    final filters = ref.watch(documentListFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar ${widget.documentType}'),
        backgroundColor: const Color(0xFF1B3A6A),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(filteredDocumentsProvider(widget.documentType).future),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Bar Pencarian
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari berdasarkan nama...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(documentListFilterProvider.notifier)
                            .update((state) => {...state, 'name': value});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 28),
                    onPressed: () => _selectDateRange(context),
                    tooltip: 'Filter Tanggal',
                  ),
                ],
              ),
              if (filters['startDate'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text(
                      '${DateFormat('dd/MM/yy').format(filters['startDate'])} - ${DateFormat('dd/MM/yy').format(filters['endDate'])}',
                    ),
                    onDeleted: () {
                      ref.read(documentListFilterProvider.notifier).update((
                        state,
                      ) {
                        return {...state, 'startDate': null, 'endDate': null};
                      });
                    },
                  ),
                ),
              const Divider(height: 32),

              // Daftar Dokumen
              Expanded(
                child: documentsProvider.when(
                  data: (documents) {
                    if (documents.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada dokumen ditemukan.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: documents.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          leading: Icon(
                            Icons.article_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 36,
                          ),
                          title: Text(
                            doc.fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Diunggah: ${DateFormat('dd MMMM yyyy').format(doc.createdAt)}',
                          ),
                          // Tombol Download
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.download_for_offline_outlined,
                              color: Colors.blueGrey,
                            ),
                            tooltip: 'Unduh File',
                            onPressed: () async {
                              // Panggil fungsi download dengan menyertakan `ref`
                              await _downloadService.downloadFile(
                                context: context,
                                ref: ref, // <--- Perubahan di sini
                                url: doc.fileUrl,
                                fileName: doc.fileName,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
