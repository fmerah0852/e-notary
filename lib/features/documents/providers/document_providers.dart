import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_notary/features/documents/models/document_model.dart';
import 'package:e_notary/features/documents/repositories/document_repository.dart';

// Provider untuk DocumentRepository
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

// Provider untuk mengambil data dokumen
final documentsProvider = FutureProvider<List<Document>>((ref) async {
  return ref.watch(documentRepositoryProvider).fetchDocuments();
});
