import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // .. Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String pEmail,
    String pPassword,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: pEmail,
      password: pPassword,
    );
  }

  // .. Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String pEmail,
    String pPassword,
  ) async {
    return _supabase.auth.signUp(email: pEmail, password: pPassword);
  }

  // .. Sign out
  Future<void> singOut() async {
    await _supabase.auth.signOut();
  }

  // .. get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
