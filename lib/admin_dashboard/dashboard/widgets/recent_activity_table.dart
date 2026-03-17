import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class RecentActivityTable extends StatelessWidget {
  const RecentActivityTable({super.key});

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
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 860;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _RecentActivityHeader(),
              const SizedBox(height: 22),
              if (compact)
                Column(
                  children: _activities
                      .map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ActivityListCard(activity: activity),
                        ),
                      )
                      .toList(growable: false),
                )
              else
                const _DesktopActivityTable(),
            ],
          );
        },
      ),
    );
  }
}

class _RecentActivityHeader extends StatelessWidget {
  const _RecentActivityHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Recent Activity',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Latest updates across the internship system',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _DesktopActivityTable extends StatelessWidget {
  const _DesktopActivityTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: const <Widget>[
              _TableHeaderCell(label: 'User / Entity', flex: 3),
              _TableHeaderCell(label: 'Action', flex: 4),
              _TableHeaderCell(label: 'Role', flex: 2),
              _TableHeaderCell(label: 'Time', flex: 2),
              _TableHeaderCell(label: 'Status', flex: 2),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._activities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityTableRow(activity: activity),
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.tableHeader.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ActivityTableRow extends StatefulWidget {
  const _ActivityTableRow({required this.activity});

  final ActivityItem activity;

  @override
  State<_ActivityTableRow> createState() => _ActivityTableRowState();
}

class _ActivityTableRowState extends State<_ActivityTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.hover : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? AppColors.coolSky.withOpacity(0.18)
                : AppColors.border,
          ),
          boxShadow: _isHovered
              ? const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(flex: 3, child: _EntityCell(activity: widget.activity)),
            Expanded(
              flex: 4,
              child: Text(
                widget.activity.action,
                style: AppTextStyles.tableCell.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.activity.role,
                style: AppTextStyles.tableCell.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.activity.time,
                style: AppTextStyles.tableCell.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.activity.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityListCard extends StatefulWidget {
  const _ActivityListCard({required this.activity});

  final ActivityItem activity;

  @override
  State<_ActivityListCard> createState() => _ActivityListCardState();
}

class _ActivityListCardState extends State<_ActivityListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.hover : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered
                ? AppColors.coolSky.withOpacity(0.18)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _EntityCell(activity: widget.activity)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.activity.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.activity.action,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: <Widget>[
                _InfoPill(
                  label: widget.activity.role,
                  icon: Icons.badge_rounded,
                ),
                _InfoPill(
                  label: widget.activity.time,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityCell extends StatelessWidget {
  const _EntityCell({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: activity.accentColor.withOpacity(0.18),
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            activity.entity,
            style: AppTextStyles.tableCell.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  const ActivityItem({
    required this.entity,
    required this.action,
    required this.role,
    required this.time,
    required this.status,
    required this.initials,
    required this.accentColor,
  });

  final String entity;
  final String action;
  final String role;
  final String time;
  final ActivityStatus status;
  final String initials;
  final Color accentColor;
}

enum ActivityStatus {
  pending(
    label: 'Pending',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  ),
  approved(
    label: 'Approved',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  updated(
    label: 'Updated',
    color: AppColors.coolSky,
    backgroundColor: AppColors.primarySoft,
  ),
  review(
    label: 'Review',
    color: AppColors.jasmine,
    backgroundColor: Color(0xFFFFF8D8),
  ),
  sent(
    label: 'Sent',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  );

  const ActivityStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}

const List<ActivityItem> _activities = <ActivityItem>[
  ActivityItem(
    entity: 'Aditi Sharma',
    action: 'Submitted weekly report',
    role: 'Student',
    time: '10 mins ago',
    status: ActivityStatus.pending,
    initials: 'AS',
    accentColor: AppColors.coolSky,
  ),
  ActivityItem(
    entity: 'Rahul Verma',
    action: 'Approved internship request',
    role: 'Faculty Mentor',
    time: '25 mins ago',
    status: ActivityStatus.approved,
    initials: 'RV',
    accentColor: AppColors.aquamarine,
  ),
  ActivityItem(
    entity: 'TCS Pune',
    action: 'Company profile updated',
    role: 'Company',
    time: '1 hour ago',
    status: ActivityStatus.updated,
    initials: 'TC',
    accentColor: AppColors.tangerineDream,
  ),
  ActivityItem(
    entity: 'Meera Joshi',
    action: 'Requested mentor reassignment',
    role: 'Student',
    time: '2 hours ago',
    status: ActivityStatus.review,
    initials: 'MJ',
    accentColor: AppColors.jasmine,
  ),
  ActivityItem(
    entity: 'HOD IT Dept',
    action: 'Published internship notice',
    role: 'HOD',
    time: 'Today',
    status: ActivityStatus.sent,
    initials: 'HD',
    accentColor: AppColors.strawberryRed,
  ),
];
