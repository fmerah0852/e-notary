import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_notary/features/auth/providers/auth_providers.dart';
import 'package:e_notary/features/auth/screens/login_screen.dart';
import 'package:e_notary/features/documents/screens/home_screen.dart';
import 'package:e_notary/features/auth/screens/reset_password_screen.dart'; // <-- Impor halaman baru
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Pindahkan listener ke initState agar bisa melakukan navigasi
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Jika event-nya adalah pemulihan password, buka halaman Reset Password
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sisa dari logic build tetap sama
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
