import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/dashboard_chart_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/overview_banner.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_activity_table.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _AnimatedSection(
            delay: Duration(milliseconds: 20),
            child: OverviewBanner(
              title: 'Welcome back, Admin',
              subtitle:
                  'Here is today\'s internship overview across students, approvals, mentors, and reporting activity.',
              highlightLabel: 'Active this week',
              highlightValue: '128 internships',
              secondaryLabel: 'Approval turnaround',
              secondaryValue: '2.4 days avg',
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Key Metrics',
            subtitle: 'Track operational health at a glance.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columnCount = _resolveColumns(
                width: constraints.maxWidth,
                minTileWidth: 220,
              );
              final double spacing = 18;
              final double tileWidth =
                  (constraints.maxWidth - ((columnCount - 1) * spacing)) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _kpiData
                    .asMap()
                    .entries
                    .map((entry) {
                      final int index = entry.key;
                      final _KpiData data = entry.value;

                      return SizedBox(
                        width: tileWidth,
                        child: KpiCard(
                          title: data.title,
                          value: data.value,
                          icon: data.icon,
                          accentColor: data.accentColor,
                          trendLabel: data.trend,
                          trendUp: data.trendUp,
                          animationDelay: Duration(milliseconds: 80 * index),
                        ),
                      );
                    })
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 32),
          _SectionHeader(
            title: 'Analytics Overview',
            subtitle: 'Visualize internship growth and current program status.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 980;

              if (isCompact) {
                return Column(
                  children: const <Widget>[
                    SizedBox(
                      height: 360,
                      child: DashboardChartCard.line(
                        title: 'Internship Trend',
                        subtitle:
                            'Monthly internship participation across the latest cycle.',
                        lineData: _trendChartData,
                        animationDelay: Duration(milliseconds: 120),
                      ),
                    ),
                    SizedBox(height: 18),
                    SizedBox(
                      height: 360,
                      child: DashboardChartCard.donut(
                        title: 'Internship Status',
                        subtitle:
                            'Distribution of active, completed, and pending internships.',
                        donutData: _statusChartData,
                        animationDelay: Duration(milliseconds: 200),
                      ),
                    ),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 360,
                      child: DashboardChartCard.line(
                        title: 'Internship Trend',
                        subtitle:
                            'Monthly internship participation across the latest cycle.',
                        lineData: _trendChartData,
                        animationDelay: Duration(milliseconds: 120),
                      ),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 360,
                      child: DashboardChartCard.donut(
                        title: 'Internship Status',
                        subtitle:
                            'Distribution of active, completed, and pending internships.',
                        donutData: _statusChartData,
                        animationDelay: Duration(milliseconds: 200),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _SectionHeader(
            title: 'Quick Actions',
            subtitle: 'Start the most common admin workflows instantly.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columnCount = _resolveColumns(
                width: constraints.maxWidth,
                minTileWidth: 240,
              );
              final double spacing = 18;
              final double tileWidth =
                  (constraints.maxWidth - ((columnCount - 1) * spacing)) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _actionData
                    .asMap()
                    .entries
                    .map((entry) {
                      final int index = entry.key;
                      final _ActionData data = entry.value;

                      return SizedBox(
                        width: tileWidth,
                        child: QuickActionCard(
                          title: data.title,
                          subtitle: data.subtitle,
                          icon: data.icon,
                          accentColor: data.accentColor,
                          animationDelay: Duration(milliseconds: 90 * index),
                        ),
                      );
                    })
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 32),
          const _AnimatedSection(
            delay: Duration(milliseconds: 240),
            child: RecentActivityTable(),
          ),
          const SizedBox(height: 32),
          const _AnimatedSection(
            delay: Duration(milliseconds: 280),
            child: _StatusPanel(),
          ),
        ],
      ),
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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 760;

          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    _StatusHeader(),
                    SizedBox(height: 20),
                    _StatusHighlights(),
                  ],
                )
              : const Row(
                  children: <Widget>[
                    Expanded(child: _StatusHeader()),
                    SizedBox(width: 20),
                    Expanded(child: _StatusHighlights()),
                  ],
                );
        },
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Today\'s Operational Pulse',
          style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 10),
        Text(
          'The dashboard foundation is ready for live charts, Firebase streams, and review tables. This summary area gives you a polished space for daily operational insight.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary.withOpacity(0.72),
          ),
        ),
      ],
    );
  }
}

class _StatusHighlights extends StatelessWidget {
  const _StatusHighlights();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: const <Widget>[
        _MiniHighlight(
          title: 'Mentor Coverage',
          value: '92%',
          accentColor: AppColors.aquamarine,
        ),
        _MiniHighlight(
          title: 'Report Completion',
          value: '84%',
          accentColor: AppColors.coolSky,
        ),
        _MiniHighlight(
          title: 'Escalations',
          value: '07',
          accentColor: AppColors.tangerineDream,
        ),
      ],
    );
  }
}

class _MiniHighlight extends StatelessWidget {
  const _MiniHighlight({
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 560 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.trend,
    this.trendUp = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String trend;
  final bool trendUp;
}

class _ActionData {
  const _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

const List<_KpiData> _kpiData = <_KpiData>[
  _KpiData(
    title: 'Total Students',
    value: '1,284',
    icon: Icons.school_rounded,
    accentColor: AppColors.coolSky,
    trend: '+12.4%',
  ),
  _KpiData(
    title: 'Active Internships',
    value: '428',
    icon: Icons.work_history_rounded,
    accentColor: AppColors.aquamarine,
    trend: '+8.1%',
  ),
  _KpiData(
    title: 'Pending Approvals',
    value: '36',
    icon: Icons.pending_actions_rounded,
    accentColor: AppColors.jasmine,
    trend: '-4.2%',
    trendUp: false,
  ),
  _KpiData(
    title: 'Reports Submitted',
    value: '312',
    icon: Icons.assignment_turned_in_rounded,
    accentColor: AppColors.tangerineDream,
    trend: '+15.8%',
  ),
];

const List<_ActionData> _actionData = <_ActionData>[
  _ActionData(
    title: 'Approve Requests',
    subtitle: 'Review newly submitted internship and onboarding requests.',
    icon: Icons.arrow_outward_rounded,
    accentColor: AppColors.jasmine,
  ),
  _ActionData(
    title: 'View Reports',
    subtitle: 'Open progress reports and audit the latest submissions.',
    icon: Icons.bar_chart_rounded,
    accentColor: AppColors.coolSky,
  ),
  _ActionData(
    title: 'Add Mentor',
    subtitle: 'Create a new mentor record and assign guidance coverage.',
    icon: Icons.person_add_alt_1_rounded,
    accentColor: AppColors.aquamarine,
  ),
  _ActionData(
    title: 'Send Notification',
    subtitle: 'Push a platform-wide message to students, mentors, or admins.',
    icon: Icons.notifications_active_rounded,
    accentColor: AppColors.strawberryRed,
  ),
];

const DashboardLineChartData _trendChartData = DashboardLineChartData(
  points: <DashboardLinePoint>[
    DashboardLinePoint(label: 'Jan', value: 40),
    DashboardLinePoint(label: 'Feb', value: 55),
    DashboardLinePoint(label: 'Mar', value: 70),
    DashboardLinePoint(label: 'Apr', value: 90),
    DashboardLinePoint(label: 'May', value: 110),
  ],
);

const DashboardDonutChartData _statusChartData = DashboardDonutChartData(
  sections: <DashboardDonutSectionData>[
    DashboardDonutSectionData(
      label: 'Active',
      value: 110,
      color: AppColors.coolSky,
    ),
    DashboardDonutSectionData(
      label: 'Completed',
      value: 72,
      color: AppColors.aquamarine,
    ),
    DashboardDonutSectionData(
      label: 'Pending',
      value: 28,
      color: AppColors.tangerineDream,
    ),
  ],
);
