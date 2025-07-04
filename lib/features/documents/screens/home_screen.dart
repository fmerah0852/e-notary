import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_notary/features/auth/providers/auth_providers.dart';
import 'package:e_notary/features/documents/screens/upload_screen.dart';
import 'package:e_notary/features/documents/screens/search_screen.dart';
import 'package:e_notary/shared/widgets/dashboard_button.dart'; // Pastikan path ini benar
import 'package:e_notary/features/documents/screens/document_list_screen.dart'; // Impor halaman baru

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data untuk tombol-tombol di dashboard
    final List<Map<String, dynamic>> dashboardItems = [
      // ... Tombol Unggah dan Cari tidak berubah
      {
        'icon': Icons.cloud_upload_outlined,
        'label': 'Unggah Dokumen',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadScreen()),
        ),
      },
      {
        'icon': Icons.search_outlined,
        'label': 'Cari Dokumen',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        ),
      },

      // Perbarui tombol-tombol ini
      {
        'icon': Icons.book_outlined,
        'label': 'Repertorium',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Repertorium'),
          ),
        ),
      },
      {
        'icon': Icons.article_outlined,
        'label': 'Akta',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Akta'),
          ),
        ),
      },
      {
        'icon': Icons.verified_user_outlined,
        'label': 'Legalisasi',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Legalisasi'),
          ),
        ),
      },
      {
        'icon': Icons.check_box_outlined,
        'label': 'Waarmeking',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Waarmeking'),
          ),
        ),
      },
      {
        'icon': Icons.add_to_photos_outlined,
        'label': 'Wasiat',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Wasiat'),
          ),
        ),
      },
      {
        'icon': Icons.people_alt_outlined,
        'label': 'Waris',
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DocumentListScreen(documentType: 'Waris'),
          ),
        ),
      },
    ];

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Warna latar belakang yang lebih cerah
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'e-Notary',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B3A6A),
                            ),
                      ),
                      Text(
                        'Platform Notarisasi Digital Terpercaya',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF1B3A6A),
                      size: 28,
                    ),
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Grid Tombol Dashboard
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // Menyesuaikan rasio tombol
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return DashboardButton(
                      icon: item['icon'],
                      label: item['label'],
                      onTap: item['action'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
