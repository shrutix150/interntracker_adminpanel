import 'package:flutter/material.dart';

import '../dashboard/screens/dashboard_home_screen.dart';
import '../approvals/screens/approvals_screen.dart';
import '../companies/screens/companies_screen.dart';
import '../mentors/screens/mentors_screen.dart';
import '../notifications/screens/notifications_screen.dart';
import '../students/screens/students_screen.dart';
import '../hod/hod_management_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'admin_navigation_item.dart';

class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key, required this.selectedItem});

  final AdminNavigationItem selectedItem;

  @override
  Widget build(BuildContext context) {
    switch (selectedItem) {
      case AdminNavigationItem.dashboard:
        return const DashboardHomeScreen();
      case AdminNavigationItem.approvals:
        return const ApprovalsScreen();
      case AdminNavigationItem.students:
        return const StudentsScreen();
      case AdminNavigationItem.mentors:
        return const MentorsScreen();
      case AdminNavigationItem.companies:
        return const CompaniesScreen();
      case AdminNavigationItem.notifications:
        return const NotificationsScreen();
      case AdminNavigationItem.hodManagement:
        return const HodManagementScreen();
      case AdminNavigationItem.settings:
        return const _AdminProfilePage();
      case AdminNavigationItem.logout:
        return const _SectionPlaceholderPage(
          title: 'Logout',
          eyebrow: 'Session Management',
          description:
              'Use this entry point to connect your authentication flow and secure administrator sign-out experience.',
          accentColor: AppColors.strawberryRed,
          icon: Icons.logout_rounded,
        );
    }
  }
}

class _DashboardPlaceholderPage extends StatelessWidget {
  const _DashboardPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 980;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.coolSky.withOpacity(0.18),
                    AppColors.aquamarine.withOpacity(0.16),
                    AppColors.jasmine.withOpacity(0.24),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.surface.withOpacity(0.9)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 30,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: isCompact
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _DashboardHeroContent(),
                        SizedBox(height: 20),
                        _DashboardNextLayerCard(),
                      ],
                    )
                  : const Row(
                      children: <Widget>[
                        Expanded(child: _DashboardHeroContent()),
                        SizedBox(width: 24),
                        _DashboardNextLayerCard(),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: _SectionPlaceholderPage(
                title: 'Dashboard Workspace',
                eyebrow: 'Foundation Ready',
                description:
                    'This area is prepared for your analytics cards, trend charts, approval feed, and operational tables.',
                accentColor: AppColors.coolSky,
                icon: Icons.space_dashboard_rounded,
                compact: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardHeroContent extends StatelessWidget {
  const _DashboardHeroContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Executive Overview',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your premium InternTracker dashboard base is ready.',
          style: AppTextStyles.display.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'Connect charts, approvals, tables, and Firebase-powered activity streams into this shell without changing the layout foundation.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const <Widget>[
            _MetricChip(
              label: 'Active interns',
              value: '248',
              accent: AppColors.coolSky,
            ),
            _MetricChip(
              label: 'Pending approvals',
              value: '18',
              accent: AppColors.jasmine,
            ),
            _MetricChip(
              label: 'Partner companies',
              value: '36',
              accent: AppColors.aquamarine,
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardNextLayerCard extends StatelessWidget {
  const _DashboardNextLayerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surface.withOpacity(0.92)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Next layer', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Text(
            'Replace this panel with your live KPI widgets, charts, or approval summaries.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionPlaceholderPage extends StatelessWidget {
  const _SectionPlaceholderPage({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.accentColor,
    required this.icon,
    this.compact = false,
  });

  final String title;
  final String eyebrow;
  final String description;
  final Color accentColor;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding = compact
        ? const EdgeInsets.all(24)
        : const EdgeInsets.symmetric(horizontal: 28, vertical: 30);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accentColor.withOpacity(0.94),
                  AppColors.surface,
                ],
              ),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(height: 22),
          Text(
            eyebrow,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.pageTitle),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.74),
              ),
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _MiniInfoCard(
                title: 'Ready for tables',
                subtitle: 'Connect structured data listings here.',
                accentColor: accentColor,
              ),
              _MiniInfoCard(
                title: 'Ready for filters',
                subtitle: 'Add search, sort, and filter controls.',
                accentColor: AppColors.aquamarine,
              ),
              _MiniInfoCard(
                title: 'Ready for charts',
                subtitle: 'Drop in trend lines and summary widgets.',
                accentColor: AppColors.tangerineDream,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminProfilePage extends StatelessWidget {
  const _AdminProfilePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 0, right: 0, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Admin Profile', style: AppTextStyles.pageTitle),
          const SizedBox(height: 8),
          Text(
            'Review your account information, organization details, and system settings in one place.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.74),
            ),
          ),
          const SizedBox(height: 28),
          _ProfileSection(
            title: 'Admin Details',
            children: <Widget>[
              _ProfileTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'admin@interntracker.com',
              ),
              _ProfileTile(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: 'Admin',
              ),
              _ProfileTile(
                icon: Icons.account_balance_rounded,
                label: 'College Name',
                value: 'Government Polytechnic Chhatrapati Sambhajinagar',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileSection(
            title: 'Organization Details',
            children: <Widget>[
              _ProfileTile(
                icon: Icons.account_balance_rounded,
                label: 'College Name',
                value: 'Government Polytechnic Chhatrapati Sambhajinagar',
              ),
              _ProfileTile(
                icon: Icons.code_rounded,
                label: 'Institute Code',
                value: '02010',
              ),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: 'Station Road, Usmanpura, Rachanakar Colony, New Usmanpura, Chhatrapati Sambhajinagar, Maharashtra 431005',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileSection(
            title: 'System Info',
            children: <Widget>[
              _ProfileTile(
                icon: Icons.info_outline,
                label: 'App Name',
                value: 'InternTracker Admin',
              ),
              _ProfileTile(
                icon: Icons.system_update_alt_rounded,
                label: 'Version',
                value: '1.0',
              ),
              _ProfileTile(
                icon: Icons.cloud_outlined,
                label: 'Database',
                value: 'Firebase',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileSection(
            title: 'Account Actions',
            children: <Widget>[
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile action coming soon.')),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password action coming soon.') ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
          ),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.coolSky),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.aquamarine),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surface.withOpacity(0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.76),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
