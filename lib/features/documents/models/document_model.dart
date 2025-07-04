class Document {
  final String id;
  final String fileName;
  final String fileUrl;
  final DateTime createdAt;
  final String documentType;

  Document({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.createdAt,
    required this.documentType,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as String,
      fileName: map['file_name'] as String,
      fileUrl: map['file_url'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      documentType: map['document_type'] as String,
    );
  }
}
