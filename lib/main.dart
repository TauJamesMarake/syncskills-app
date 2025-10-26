import 'package:flutter/material.dart';
import 'package:syncskills/services/auth_gate.dart';
//import 'package:get/get.dart'; // Change: Import GetX
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
// import 'package:syncskills/views/profile_setup/complete_profile_screen.dart';
// import 'package:syncskills/views/profile_setup/completed_trainings_screen.dart';
// import 'package:syncskills/views/profile_setup/profile_setup_screen.dart';
// import 'package:syncskills/views/profile_setup/skills_selection_screen.dart';
// import 'package:syncskills/widget_tree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: "https://fdbnblfkaadojtobrfcn.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkYm5ibGZrYWFkb2p0b2JyZmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4NzY1NzIsImV4cCI6MjA3NjQ1MjU3Mn0.QLbt1SB95RRf993Nai3IJ2MJvoDrBwEEJjlgDTFHSFc",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // .. Theme styling
      theme: ThemeData(
        // .. AppBar theme
        appBarTheme: const AppBarTheme(centerTitle: true),

        // .. Elevatedbutton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,

            textStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),

            // ..
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      // .. Routes
      // AuthGate()
      home: AuthGate(),
    );
  }
}
