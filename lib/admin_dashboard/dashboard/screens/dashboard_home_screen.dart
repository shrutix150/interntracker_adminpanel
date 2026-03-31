import 'package:flutter/material.dart';

import '../../../auth/admin_auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../dashboard_controller.dart';
import '../widgets/dashboard_chart_card.dart';
import '../widgets/recent_activity_table.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final DashboardController _controller = DashboardController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardOverview>(
      stream: _controller.watchOverview(),
      builder: (context, snapshot) {
        final bool hasError = snapshot.hasError;
        final bool isLoading = !snapshot.hasData && !hasError;
        final DashboardOverview overview =
            snapshot.data ?? _fallbackOverview();
        final DashboardStats stats = overview.stats;

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _InfoBanner(
                  title: 'Dashboard Notice',
                  message:
                      'Unable to load live dashboard data right now. ${snapshot.error}',
                  color: AppColors.strawberryRed,
                  icon: Icons.error_outline_rounded,
                ),
              )
            else if (isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _LoadingBanner(),
              ),
            _HeroCard(overview: overview),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Key Metrics',
              subtitle: 'Live counts from your Firebase user collection.',
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final int columns = _resolveColumns(
                  width: constraints.maxWidth,
                  minTileWidth: 220,
                );
                final double spacing = 16;
                final double itemWidth =
                    (constraints.maxWidth - ((columns - 1) * spacing)) /
                    columns;

                final List<_MetricCardData> cards = <_MetricCardData>[
                  _MetricCardData(
                    title: 'Total Students',
                    value: stats.totalStudents.toString(),
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                  ),
                  _MetricCardData(
                    title: 'Total Faculty',
                    value: stats.totalFaculty.toString(),
                    icon: Icons.groups_rounded,
                    color: AppColors.aquamarine,
                  ),
                  _MetricCardData(
                    title: 'Pending Approvals',
                    value: stats.pendingApprovals.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.tangerineDream,
                  ),
                  _MetricCardData(
                    title: 'Active Internships',
                    value: stats.activeInternships.toString(),
                    icon: Icons.work_history_rounded,
                    color: AppColors.coolSky,
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: itemWidth,
                          child: _MetricCard(data: card),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Overview',
              subtitle: 'Quick operational summary based on live Firebase data.',
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 920;

                if (compact) {
                  return Column(
                    children: <Widget>[
                      _SummaryCard(
                        title: 'Internship Status',
                        rows: <_SummaryRowData>[
                          _SummaryRowData(
                            label: 'Active',
                            value: stats.activeInternships.toString(),
                            color: AppColors.coolSky,
                          ),
                          _SummaryRowData(
                            label: 'This Week',
                            value: overview.activeThisWeek.toString(),
                            color: AppColors.aquamarine,
                          ),
                          _SummaryRowData(
                            label: 'Queue',
                            value: overview.approvalTurnaroundLabel,
                            color: AppColors.tangerineDream,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SummaryCard(
                        title: 'Student Approval Snapshot',
                        rows: <_SummaryRowData>[
                          _SummaryRowData(
                            label: 'Approval Rate',
                            value: '${overview.approvalRate}%',
                            color: AppColors.aquamarine,
                          ),
                          _SummaryRowData(
                            label: 'Approved',
                            value: overview.approvedStudents.toString(),
                            color: AppColors.coolSky,
                          ),
                          _SummaryRowData(
                            label: 'Pending',
                            value: overview.pendingStudents.toString(),
                            color: AppColors.tangerineDream,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _SummaryCard(
                        title: 'Internship Status',
                        rows: <_SummaryRowData>[
                          _SummaryRowData(
                            label: 'Active',
                            value: stats.activeInternships.toString(),
                            color: AppColors.coolSky,
                          ),
                          _SummaryRowData(
                            label: 'This Week',
                            value: overview.activeThisWeek.toString(),
                            color: AppColors.aquamarine,
                          ),
                          _SummaryRowData(
                            label: 'Queue',
                            value: overview.approvalTurnaroundLabel,
                            color: AppColors.tangerineDream,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Student Approval Snapshot',
                        rows: <_SummaryRowData>[
                          _SummaryRowData(
                            label: 'Approval Rate',
                            value: '${overview.approvalRate}%',
                            color: AppColors.aquamarine,
                          ),
                          _SummaryRowData(
                            label: 'Approved',
                            value: overview.approvedStudents.toString(),
                            color: AppColors.coolSky,
                          ),
                          _SummaryRowData(
                            label: 'Pending',
                            value: overview.pendingStudents.toString(),
                            color: AppColors.tangerineDream,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Recent Activity',
              subtitle: 'Latest records mapped from Firebase users.',
            ),
            const SizedBox(height: 16),
            _ActivityPanel(activities: overview.activities),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Admin Role Creation',
              subtitle:
                  'Create Principal and HOD accounts and save them to Firebase.',
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 920;

                if (compact) {
                  return Column(
                    children: <Widget>[
                      _RoleCreationCard(
                        title: 'Create Principal',
                        subtitle:
                            'Register the principal account with email, password, and profile details.',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.coolSky,
                        role: 'principal',
                        onCreate: () => _showRoleCreationDialog('principal'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCreationCard(
                        title: 'Create HOD',
                        subtitle:
                            'Add a head of department account and store it in Firebase user records.',
                        icon: Icons.account_tree_rounded,
                        color: AppColors.aquamarine,
                        role: 'hod',
                        onCreate: () => _showRoleCreationDialog('hod'),
                      ),
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: _RoleCreationCard(
                        title: 'Create Principal',
                        subtitle:
                            'Register the principal account with email, password, and profile details.',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.coolSky,
                        role: 'principal',
                        onCreate: () => _showRoleCreationDialog('principal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCreationCard(
                        title: 'Create HOD',
                        subtitle:
                            'Add a head of department account and store it in Firebase user records.',
                        icon: Icons.account_tree_rounded,
                        color: AppColors.aquamarine,
                        role: 'hod',
                        onCreate: () => _showRoleCreationDialog('hod'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  static int _resolveColumns({
    required double width,
    required double minTileWidth,
  }) {
    if (width >= minTileWidth * 4) {
      return 4;
    }
    if (width >= minTileWidth * 3) {
      return 3;
    }
    if (width >= minTileWidth * 2) {
      return 2;
    }
    return 1;
  }

  static DashboardOverview _fallbackOverview() {
    return DashboardOverview(
      stats: const DashboardStats(
        totalStudents: 0,
        totalFaculty: 0,
        pendingApprovals: 0,
        activeInternships: 0,
      ),
      activeThisWeek: 0,
      approvalTurnaroundLabel: 'No live data yet',
      lineChartData: const DashboardLineChartData(points: <DashboardLinePoint>[]),
      donutChartData: const DashboardDonutChartData(
        sections: <DashboardDonutSectionData>[],
      ),
      activities: const <ActivityItem>[],
      approvalRate: 0,
      approvedStudents: 0,
      pendingStudents: 0,
    );
  }

  Future<void> _showRoleCreationDialog(String role) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController departmentController = TextEditingController();
    final TextEditingController employeeIdController = TextEditingController();
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                role == 'principal' ? 'Create Principal' : 'Create HOD',
                style: AppTextStyles.sectionTitle,
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _AdminInputField(
                          controller: nameController,
                          label: 'Full Name',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: emailController,
                          label: 'Email',
                          required: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: passwordController,
                          label: 'Password',
                          required: true,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: phoneController,
                          label: 'Phone Number',
                          required: true,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: departmentController,
                          label: 'Department',
                          required: role == 'hod',
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: employeeIdController,
                          label: 'Employee ID',
                          required: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            await AdminAuthController.instance.createManagedUser(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              role: role,
                              phoneNumber: phoneController.text.trim(),
                              department: departmentController.text.trim(),
                              employeeId: employeeIdController.text.trim(),
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${role.toUpperCase()} account created successfully.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } on AdminAuthException catch (error) {
                            setDialogState(() => saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withOpacity(0.20),
            AppColors.coolSky.withOpacity(0.10),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 820;

          final Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'InternTracker Command Center',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome back, Admin',
                style: AppTextStyles.display.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                'Track approvals, students, and internship activity from Firebase in one place.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.76),
                ),
              ),
            ],
          );

          final Widget stats = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.84),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _HeroStat(
                  label: 'Active this week',
                  value: '${overview.activeThisWeek} internships',
                  color: AppColors.coolSky,
                ),
                const SizedBox(height: 16),
                _HeroStat(
                  label: 'Approval queue',
                  value: overview.approvalTurnaroundLabel,
                  color: AppColors.aquamarine,
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                content,
                const SizedBox(height: 20),
                stats,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: content),
              const SizedBox(width: 20),
              SizedBox(width: 280, child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 6,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(data.icon, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 18),
                Text(
                  data.value,
                  style: AppTextStyles.display.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(data.title, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRowData {
  const _SummaryRowData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_SummaryRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 18),
          ...rows
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: row.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(row.label, style: AppTextStyles.body),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          row.value,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: activities.isEmpty
          ? Text(
              'No recent activity available yet.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            )
          : Column(
              children: activities.map<Widget>((ActivityItem activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: activity.accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            activity.initials,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                activity.entity,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.action,
                                style: AppTextStyles.body,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${activity.role} • ${activity.time}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
    );
  }
}

class _RoleCreationCard extends StatelessWidget {
  const _RoleCreationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.role,
    required this.onCreate,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String role;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Role: ${role.toUpperCase()}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text('Create ${role.toUpperCase()}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminInputField extends StatelessWidget {
  const _AdminInputField({
    required this.controller,
    required this.label,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: required
          ? (value) =>
              (value ?? '').trim().isEmpty ? 'This field is required.' : null
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 6,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 4),
                Text(message, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    return const _InfoBanner(
      title: 'Loading',
      message: 'Loading live dashboard data from Firebase...',
      color: AppColors.primary,
      icon: Icons.hourglass_top_rounded,
    );
  }
}
