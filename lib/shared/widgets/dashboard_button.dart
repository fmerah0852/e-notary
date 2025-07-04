// Di dalam file lib/shared/widgets/dashboard_button.dart
import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.blueGrey.withOpacity(0.2), // Bayangan lebih lembut
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Sudut lebih bulat
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color(0xFF1B3A6A),
            ), // Ikon lebih besar
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600, // Sedikit lebih tebal
                fontSize: 15,
                color: Color(0xFF1B3A6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
