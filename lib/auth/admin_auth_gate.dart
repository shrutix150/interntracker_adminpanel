import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../admin_dashboard/main/admin_dashboard_shell.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/text_styles.dart';
import 'admin_auth_controller.dart';
import 'admin_login_screen.dart';

class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const _WebOnlyScreen();
    }

    return FutureBuilder<void>(
      future: AdminAuthController.instance.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !AdminAuthController.instance.initialized) {
          return const _AuthLoadingScreen();
        }

        return ListenableBuilder(
          listenable: AdminAuthController.instance,
          builder: (context, _) {
            if (AdminAuthController.instance.isAuthenticated) {
              return const AdminDashboardShell();
            }

            return const AdminLoginScreen();
          },
        );
      },
    );
  }
}

class _WebOnlyScreen extends StatelessWidget {
  const _WebOnlyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.background,
              AppColors.coolSky.withOpacity(0.08),
              AppColors.aquamarine.withOpacity(0.06),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 26,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.web_rounded,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Admin panel is available on web only.',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.background,
              AppColors.coolSky.withOpacity(0.08),
              AppColors.aquamarine.withOpacity(0.06),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 26,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 18),
                Text(
                  'Checking admin session...',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
