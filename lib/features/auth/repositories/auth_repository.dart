import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Stream untuk memantau perubahan status login
  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange.map(
    (authState) => authState.session?.user,
  );

  User? get currentUser => _client.auth.currentUser;

  // Fungsi Registrasi
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } on AuthException catch (e) {
      // Tangani error spesifik, misal: email sudah terdaftar
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Fungsi Login
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      // Tangani error, misal: password salah
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Fungsi lupa Sandi
  // Versi Baru dengan redirectTo
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Tambahkan parameter redirectTo di sini
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.enotary.app://auth/callback',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
