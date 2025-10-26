/*

AUTH GATE - this will continuously listen to auth state changes.

----------------------------------------------------------------

unauthenticated -> Splash/Login Page
authenticated + no profile -> Profile Setup
authenticated + has profile -> Dashboard

*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/login_pages/splash_Screen.dart';
import 'package:syncskills/views/profile_setup/profile_setup_screen.dart';
import 'package:syncskills/user_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>> _checkUserProfile(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('employee_details')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        return {'exists': false, 'complete': false};
      }

      // Check if profile is complete
      final isComplete =
          profile['first_name'] != null && profile['last_name'] != null;

      return {'exists': true, 'complete': isComplete, 'data': profile};
    } catch (e) {
      print('Error checking user profile: $e');
      return {'exists': false, 'complete': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2D8F3C)),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data?.session : null;

        // User is not authenticated
        if (session == null) {
          return const SplashScreen();
        }

        // User is authenticated - check profile
        final user = session.user;

        return FutureBuilder<Map<String, dynamic>>(
          future: _checkUserProfile(user.id),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D8F3C)),
                ),
              );
            }

            final profileCheck =
                profileSnapshot.data ?? {'exists': false, 'complete': false};
            final profileExists = profileCheck['exists'] as bool;
            final profileComplete = profileCheck['complete'] as bool;

            if (profileExists && profileComplete) {
              // Profile complete -> Dashboard
              return DashboardScreen();
            } else {
              // No profile or incomplete -> Profile Setup
              return ProfileSetupScreen();
            }
          },
        );
      },
    );
  }
}
