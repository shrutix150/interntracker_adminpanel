import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'notification_compose_card.dart';
import 'target_role_selector.dart';

class NotificationHistoryList extends StatelessWidget {
  const NotificationHistoryList({
    super.key,
    required this.notifications,
    required this.onView,
    required this.onResend,
    required this.onDelete,
  });

  final List<NotificationRecord> notifications;
  final ValueChanged<NotificationRecord> onView;
  final ValueChanged<NotificationRecord> onResend;
  final ValueChanged<NotificationRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 1120;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recent Announcements',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 16),
                ...notifications.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(
                      notification: item,
                      onView: onView,
                      onResend: onResend,
                      onDelete: onDelete,
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Recent Announcements',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: const <Widget>[
                    _HeaderCell(label: 'Title', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Sent By', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Audience', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Department', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Priority', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Sent Time', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...notifications.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationRow(
                    notification: item,
                    onView: onView,
                    onResend: onResend,
                    onDelete: onDelete,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});

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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.onView,
    required this.onResend,
    required this.onDelete,
  });

  final NotificationRecord notification;
  final ValueChanged<NotificationRecord> onView;
  final ValueChanged<NotificationRecord> onResend;
  final ValueChanged<NotificationRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              notification.title,
              style: AppTextStyles.tableCell.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _BodyText(notification.senderLabel)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _BodyText(notification.audience.label)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _BodyText(notification.department)),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _PriorityChip(priority: notification.priority),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _BodyText(notification.sentTime)),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: _StatusChip(status: notification.status)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _ActionGroup(
              notification: notification,
              onView: onView,
              onResend: onResend,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onView,
    required this.onResend,
    required this.onDelete,
  });

  final NotificationRecord notification;
  final ValueChanged<NotificationRecord> onView;
  final ValueChanged<NotificationRecord> onResend;
  final ValueChanged<NotificationRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  notification.title,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                ),
              ),
              _StatusChip(status: notification.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaChip(
                label: notification.senderLabel,
                color: AppColors.tangerineDream,
              ),
              _MetaChip(
                label: notification.audience.label,
                color: AppColors.coolSky,
              ),
              _MetaChip(
                label: notification.department,
                color: AppColors.jasmine,
              ),
              _MetaChip(
                label: notification.priority.label,
                color: notification.priority.color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  notification.sentTime,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              _ActionGroup(
                notification: notification,
                onView: onView,
                onResend: onResend,
                onDelete: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.tableCell.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final NotificationPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: priority.color.withOpacity(0.18)),
      ),
      child: Text(
        priority.label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final NotificationDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.18)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.notification,
    required this.onView,
    required this.onResend,
    required this.onDelete,
  });

  final NotificationRecord notification;
  final ValueChanged<NotificationRecord> onView;
  final ValueChanged<NotificationRecord> onResend;
  final ValueChanged<NotificationRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _ActionButton(
          label: 'View',
          icon: Icons.visibility_rounded,
          color: AppColors.coolSky,
          onTap: () => onView(notification),
        ),
        _ActionButton(
          label: 'Resend',
          icon: Icons.refresh_rounded,
          color: AppColors.aquamarine,
          onTap: () => onResend(notification),
        ),
        _ActionButton(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          color: AppColors.strawberryRed,
          onTap: () => onDelete(notification),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 15, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.department,
    required this.priority,
    required this.sentTime,
    required this.status,
    required this.senderRole,
    required this.senderName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationAudienceRole audience;
  final String department;
  final NotificationPriority priority;
  final String sentTime;
  final NotificationDeliveryStatus status;
  final String senderRole;
  final String senderName;
  final DateTime? createdAt;

  String get senderLabel {
    final String normalizedRole = senderRole.trim().toLowerCase();
    if (senderName.trim().isNotEmpty && senderName.trim() != 'Unknown Sender') {
      return '$senderName (${_senderRoleLabel(normalizedRole)})';
    }
    return _senderRoleLabel(normalizedRole);
  }

  factory NotificationRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final DateTime? sentAt = _readDateTime(
      data['sentAt'] ?? data['createdAt'] ?? data['updatedAt'],
    );

    return NotificationRecord(
      id: doc.id,
      title: _readString(data['title'], fallback: 'Untitled notification'),
      message: _readString(data['message'], fallback: 'No message'),
      audience: NotificationAudienceRole.fromStorage(
        _readString(data['audience'], fallback: 'all_roles'),
      ),
      department: _readString(
        data['department'],
        fallback: 'All departments',
      ),
      priority: NotificationPriority.fromStorage(
        _readString(data['priority'], fallback: 'normal'),
      ),
      sentTime: _formatSentTime(sentAt),
      status: NotificationDeliveryStatus.fromStorage(
        _readString(data['status'], fallback: 'draft'),
      ),
      senderRole: _readString(data['senderRole'], fallback: 'unknown'),
      senderName: _readString(
        data['senderName'] ?? data['createdByName'],
        fallback: 'Unknown Sender',
      ),
      createdAt: sentAt,
    );
  }

  static String _readString(dynamic value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }

    final String normalized = value.toString().trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static String _formatSentTime(DateTime? sentAt) {
    if (sentAt == null) {
      return 'Not available';
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDay = DateTime(sentAt.year, sentAt.month, sentAt.day);
    final int difference = today.difference(targetDay).inDays;
    final String hour = ((sentAt.hour % 12 == 0) ? 12 : sentAt.hour % 12)
        .toString()
        .padLeft(2, '0');
    final String minute = sentAt.minute.toString().padLeft(2, '0');
    final String meridiem = sentAt.hour >= 12 ? 'PM' : 'AM';

    if (difference == 0) {
      return 'Today, $hour:$minute $meridiem';
    }
    if (difference == 1) {
      return 'Yesterday, $hour:$minute $meridiem';
    }
    if (difference == -1) {
      return 'Tomorrow, $hour:$minute $meridiem';
    }

    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${sentAt.day.toString().padLeft(2, '0')} '
        '${months[sentAt.month - 1]} ${sentAt.year}, $hour:$minute $meridiem';
  }

  static String _senderRoleLabel(String value) {
    switch (value) {
      case 'admin':
        return 'Admin';
      case 'hod':
      case 'hods':
        return 'HOD';
      case 'principal':
        return 'Principal';
      case 'faculty':
      case 'faculty_mentor':
      case 'facultymentor':
        return 'Faculty';
      case 'mentor':
      case 'company_mentor':
      case 'companymentor':
        return 'Mentor';
      default:
        return 'Unknown';
    }
  }
}

enum NotificationDeliveryStatus {
  sent(
    label: 'Sent',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  scheduled(
    label: 'Scheduled',
    color: AppColors.coolSky,
    backgroundColor: AppColors.primarySoft,
  ),
  failed(
    label: 'Failed',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  ),
  draft(
    label: 'Draft',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  );

  const NotificationDeliveryStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  factory NotificationDeliveryStatus.fromStorage(String value) {
    final String normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'sent':
        return NotificationDeliveryStatus.sent;
      case 'scheduled':
        return NotificationDeliveryStatus.scheduled;
      case 'failed':
        return NotificationDeliveryStatus.failed;
      default:
        return NotificationDeliveryStatus.draft;
    }
  }
}
