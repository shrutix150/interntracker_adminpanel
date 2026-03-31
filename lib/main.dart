import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth/admin_auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InternTrackerAdminApp());
}

class InternTrackerAdminApp extends StatelessWidget {
  const InternTrackerAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternTracker Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminAuthGate(),
    );
  }
}
