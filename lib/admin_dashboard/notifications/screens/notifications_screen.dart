import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/notification_compose_card.dart';
import '../widgets/notification_history_list.dart';
import '../widgets/target_role_selector.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _title = '';
  String _message = '';
  NotificationAudienceRole _selectedRole = NotificationAudienceRole.allRoles;
  String _selectedDepartment = 'All departments';
  NotificationPriority _selectedPriority = NotificationPriority.normal;
  late List<NotificationRecord> _history = _seedNotifications;

  static const List<String> _departmentOptions = <String>[
    'All departments',
    'Artificial Intelligence & Machine Learning',
    'Computer Engineering',
    'Information Technology',
    'Electronics & Telecommunication',
    'Electrical Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Automobile Engineering',
    'Dress Designing & Garment Manufacturing',
  ];

  @override
  Widget build(BuildContext context) {
    final int sentToday = _history
        .where((item) => item.status == NotificationDeliveryStatus.sent)
        .length;
    final int totalAnnouncements = _history.length;
    const int readRate = 84;
    final int pendingDelivery = _history
        .where((item) => item.status == NotificationDeliveryStatus.scheduled)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _NotificationsHero(sentToday: sentToday),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = _resolveColumns(constraints.maxWidth);
              final double spacing = 16;
              final double cardWidth =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Sent Today',
                      value: '$sentToday',
                      subtitle: 'Announcements delivered today',
                      icon: Icons.send_rounded,
                      accentColor: AppColors.coolSky,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Total Announcements',
                      value: '$totalAnnouncements',
                      subtitle: 'Across recent communication history',
                      icon: Icons.campaign_rounded,
                      accentColor: AppColors.aquamarine,
                      animationDelay: const Duration(milliseconds: 80),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Read Rate',
                      value: '$readRate%',
                      subtitle: 'Average engagement across recipients',
                      icon: Icons.mark_email_read_rounded,
                      accentColor: AppColors.jasmine,
                      animationDelay: const Duration(milliseconds: 160),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _StatCard(
                      title: 'Pending Delivery',
                      value: '$pendingDelivery',
                      subtitle: 'Scheduled announcements in queue',
                      icon: Icons.schedule_send_rounded,
                      accentColor: AppColors.tangerineDream,
                      animationDelay: const Duration(milliseconds: 240),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool stacked = constraints.maxWidth < 1180;

              if (stacked) {
                return Column(
                  children: <Widget>[
                    NotificationComposeCard(
                      title: _title,
                      message: _message,
                      selectedRole: _selectedRole,
                      selectedDepartment: _selectedDepartment,
                      selectedPriority: _selectedPriority,
                      departmentOptions: _departmentOptions,
                      onTitleChanged: (value) => setState(() => _title = value),
                      onMessageChanged: (value) =>
                          setState(() => _message = value),
                      onRoleChanged: (value) =>
                          setState(() => _selectedRole = value),
                      onDepartmentChanged: (value) =>
                          setState(() => _selectedDepartment = value),
                      onPriorityChanged: (value) =>
                          setState(() => _selectedPriority = value),
                      onSend: _handleSend,
                    ),
                    const SizedBox(height: 18),
                    NotificationHistoryList(
                      notifications: _history,
                      onView: _handleView,
                      onResend: _handleResend,
                      onDelete: _handleDelete,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: NotificationComposeCard(
                      title: _title,
                      message: _message,
                      selectedRole: _selectedRole,
                      selectedDepartment: _selectedDepartment,
                      selectedPriority: _selectedPriority,
                      departmentOptions: _departmentOptions,
                      onTitleChanged: (value) => setState(() => _title = value),
                      onMessageChanged: (value) =>
                          setState(() => _message = value),
                      onRoleChanged: (value) =>
                          setState(() => _selectedRole = value),
                      onDepartmentChanged: (value) =>
                          setState(() => _selectedDepartment = value),
                      onPriorityChanged: (value) =>
                          setState(() => _selectedPriority = value),
                      onSend: _handleSend,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 4,
                    child: NotificationHistoryList(
                      notifications: _history,
                      onView: _handleView,
                      onResend: _handleResend,
                      onDelete: _handleDelete,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    if (_title.trim().isEmpty || _message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title and message before sending.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final NotificationRecord item = NotificationRecord(
      id: 'ntf-${_history.length + 1}',
      title: _title.trim(),
      message: _message.trim(),
      audience: _selectedRole,
      department: _selectedDepartment,
      priority: _selectedPriority,
      sentTime: 'Just now',
      status: NotificationDeliveryStatus.sent,
    );

    setState(() {
      _history = <NotificationRecord>[item, ..._history];
      _title = '';
      _message = '';
      _selectedRole = NotificationAudienceRole.allRoles;
      _selectedDepartment = 'All departments';
      _selectedPriority = NotificationPriority.normal;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcement sent successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleView(NotificationRecord item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing "${item.title}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleResend(NotificationRecord item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resending "${item.title}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDelete(NotificationRecord item) {
    setState(() {
      _history = _history.where((entry) => entry.id != item.id).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${item.title}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static int _resolveColumns(double width) {
    if (width >= 960) {
      return 4;
    }
    if (width >= 720) {
      return 3;
    }
    if (width >= 460) {
      return 2;
    }
    return 1;
  }
}

class _NotificationsHero extends StatelessWidget {
  const _NotificationsHero({required this.sentToday});

  final int sentToday;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 24,
        vertical: compact ? 20 : 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.aquamarine.withOpacity(0.14),
            AppColors.coolSky.withOpacity(0.12),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surface.withOpacity(0.94)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Notifications',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create announcements and manage communication across the internship platform',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.84),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Today',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sentToday sent',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 18,
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

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Duration animationDelay;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 520 + widget.animationDelay.inMilliseconds,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 22),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withOpacity(0.2)
                  : AppColors.border,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow.withOpacity(_hovered ? 1 : 0.78),
                blurRadius: _hovered ? 24 : 18,
                offset: Offset(0, _hovered ? 14 : 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: AppTextStyles.pageTitle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<NotificationRecord> _seedNotifications = <NotificationRecord>[
  NotificationRecord(
    id: 'ntf-001',
    title: 'Weekly internship log submission reminder',
    message:
        'Please submit this week\'s internship activity log by 6:00 PM today to avoid pending review flags.',
    audience: NotificationAudienceRole.students,
    department: 'All departments',
    priority: NotificationPriority.important,
    sentTime: 'Today, 09:15 AM',
    status: NotificationDeliveryStatus.sent,
  ),
  NotificationRecord(
    id: 'ntf-002',
    title: 'Faculty review sync for pending approvals',
    message:
        'Faculty mentors are requested to review pending internship approvals before the end of the day.',
    audience: NotificationAudienceRole.facultyMentors,
    department: 'Computer Engineering',
    priority: NotificationPriority.normal,
    sentTime: 'Today, 08:30 AM',
    status: NotificationDeliveryStatus.sent,
  ),
  NotificationRecord(
    id: 'ntf-003',
    title: 'Company onboarding document checklist',
    message:
        'Pending company mentors should complete onboarding documentation before new intern allocation starts.',
    audience: NotificationAudienceRole.companyMentors,
    department: 'All departments',
    priority: NotificationPriority.important,
    sentTime: 'Tomorrow, 10:00 AM',
    status: NotificationDeliveryStatus.scheduled,
  ),
  NotificationRecord(
    id: 'ntf-004',
    title: 'Dress design department review meeting',
    message:
        'A review meeting is scheduled for department heads to discuss internship placement support for the upcoming cycle.',
    audience: NotificationAudienceRole.hods,
    department: 'Dress Designing & Garment Manufacturing',
    priority: NotificationPriority.normal,
    sentTime: 'Yesterday, 04:10 PM',
    status: NotificationDeliveryStatus.sent,
  ),
  NotificationRecord(
    id: 'ntf-005',
    title: 'Urgent attendance compliance escalation',
    message:
        'Students below attendance thresholds must connect with mentors immediately and update pending records.',
    audience: NotificationAudienceRole.allRoles,
    department: 'Information Technology',
    priority: NotificationPriority.urgent,
    sentTime: 'Yesterday, 11:25 AM',
    status: NotificationDeliveryStatus.failed,
  ),
  NotificationRecord(
    id: 'ntf-006',
    title: 'Principal briefing summary draft',
    message:
        'Draft summary for leadership on internship completion trends and placement partnership health.',
    audience: NotificationAudienceRole.principal,
    department: 'All departments',
    priority: NotificationPriority.normal,
    sentTime: 'Saved 2 hours ago',
    status: NotificationDeliveryStatus.draft,
  ),
];
