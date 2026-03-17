import 'package:flutter/material.dart';

import 'admin_dashboard/main/admin_dashboard_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const AdminDashboardShell(),
    );
  }
}
