import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class DocumentSignerScreen extends StatefulWidget {
  // Untuk demo, kita gunakan path gambar. Dalam aplikasi nyata, ini bisa URL.
  final String documentImagePath;

  const DocumentSignerScreen({super.key, required this.documentImagePath});

  @override
  State<DocumentSignerScreen> createState() => _DocumentSignerScreenState();
}

class _DocumentSignerScreenState extends State<DocumentSignerScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  Uint8List? _signatureData;

  void _showSignaturePad() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Tanda Tangan di Sini',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: Colors.grey[200],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  final data = await _signaturePadKey.currentState?.toImage();
                  final bytes = await data?.toByteData(
                    format: ui.ImageByteFormat.png,
                  );
                  if (bytes != null) {
                    setState(() {
                      _signatureData = bytes.buffer.asUint8List();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
              TextButton(
                onPressed: () {
                  _signaturePadKey.currentState?.clear();
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanda Tangan Dokumen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () {
              // Di sini logika untuk menggabungkan gambar dokumen dan tanda tangan
              // lalu menyimpannya kembali ke Supabase.
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Latar belakang: Gambar dokumen (misal: template Akta)
          Center(child: Image.asset(widget.documentImagePath)),

          // Tanda tangan yang bisa digeser dan diubah ukurannya
          if (_signatureData != null)
            Positioned(
              left: 150, // Posisi awal
              top: 400, // Posisi awal
              child: Draggable(
                feedback: Image.memory(_signatureData!, width: 150),
                childWhenDragging: Container(),
                child: Image.memory(_signatureData!, width: 150),
                onDragEnd: (details) {
                  // Update posisi tanda tangan di sini jika perlu
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSignaturePad,
        label: const Text('Tambah Tanda Tangan'),
        icon: const Icon(Icons.draw_outlined),
      ),
    );
  }
}
