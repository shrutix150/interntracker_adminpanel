import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/text_styles.dart';
import 'admin_auth_controller.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 980;

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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: compact
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const _LoginShowcase(),
                          const SizedBox(height: 24),
                          _LoginCard(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            obscurePassword: _obscurePassword,
                            errorMessage: _errorMessage,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onSubmit: _signIn,
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          const Expanded(flex: 6, child: _LoginShowcase()),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 5,
                            child: _LoginCard(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              isLoading: _isLoading,
                              obscurePassword: _obscurePassword,
                              errorMessage: _errorMessage,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              onSubmit: _signIn,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AdminAuthController.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AdminAuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to sign in right now. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

}

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.coolSky.withOpacity(0.22),
            AppColors.aquamarine.withOpacity(0.18),
            AppColors.jasmine.withOpacity(0.24),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.coolSky, AppColors.aquamarine],
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.textPrimary,
              size: 34,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'InternTracker Admin',
            style: AppTextStyles.display.copyWith(fontSize: 40, height: 1.05),
          ),
          const SizedBox(height: 16),
          Text(
            'Secure access for internship operations, approvals, student monitoring, reports, and partner management.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.76),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const _ShowcasePoint(
            icon: Icons.verified_user_rounded,
            text: 'Protected admin dashboard access',
          ),
          const SizedBox(height: 12),
          const _ShowcasePoint(
            icon: Icons.groups_rounded,
            text: 'Live Firebase-backed student and approval data',
          ),
          const SizedBox(height: 12),
          const _ShowcasePoint(
            icon: Icons.notifications_active_rounded,
            text: 'Centralized internship workflow management',
          ),
        ],
      ),
    );
  }
}

class _ShowcasePoint extends StatelessWidget {
  const _ShowcasePoint({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onToggleVisibility,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Admin Login',
              style: AppTextStyles.pageTitle.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in with your Firebase admin account to continue.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                hintText: 'admin@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final String input = (value ?? '').trim();
                if (input.isEmpty) {
                  return 'Enter your admin email.';
                }
                if (!input.contains('@')) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofillHints: const <String>[AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Enter your password.';
                }
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.strawberryRed.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
