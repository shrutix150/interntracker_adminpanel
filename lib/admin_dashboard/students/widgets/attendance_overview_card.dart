import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class AttendanceOverviewCard extends StatelessWidget {
  const AttendanceOverviewCard({
    super.key,
    required this.averageAttendance,
    required this.lowAttendanceStudents,
    required this.weeklyCheckIns,
    required this.missedLogs,
  });

  final int averageAttendance;
  final int lowAttendanceStudents;
  final int weeklyCheckIns;
  final int missedLogs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Attendance Overview',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            'Track participation consistency and identify students who may need follow-up.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _MetricTile(
            label: 'Avg Attendance',
            value: '$averageAttendance%',
            icon: Icons.event_available_rounded,
            accentColor: AppColors.aquamarine,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Low Attendance Students',
            value: '$lowAttendanceStudents',
            icon: Icons.warning_amber_rounded,
            accentColor: AppColors.tangerineDream,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Weekly Check-ins',
            value: '$weeklyCheckIns',
            icon: Icons.fact_check_rounded,
            accentColor: AppColors.coolSky,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Missed Logs',
            value: '$missedLogs',
            icon: Icons.event_busy_rounded,
            accentColor: AppColors.strawberryRed,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
