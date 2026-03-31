import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../auth/admin_auth_controller.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _title = '';
  String _message = '';
  NotificationAudienceRole _selectedRole = NotificationAudienceRole.allRoles;
  String _selectedDepartment = 'All departments';
  NotificationPriority _selectedPriority = NotificationPriority.normal;
  bool _isSending = false;
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('user').snapshots(),
      builder: (context, usersSnapshot) {
        if (usersSnapshot.hasError) {
          return _NotificationsStateCard(
            message:
                'Unable to load notification data right now. ${usersSnapshot.error}',
            icon: Icons.error_outline_rounded,
          );
        }

        if (!usersSnapshot.hasData) {
          return const _NotificationsStateCard(
            message: 'Loading notification controls from Firebase...',
            icon: Icons.hourglass_top_rounded,
            showLoader: true,
          );
        }

        final List<String> departmentOptions = _buildDepartmentOptions(
          usersSnapshot.data!.docs,
        );
        if (!departmentOptions.contains(_selectedDepartment)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            setState(() => _selectedDepartment = 'All departments');
          });
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('notifications').snapshots(),
          builder: (context, notificationsSnapshot) {
            if (notificationsSnapshot.hasError) {
              return _NotificationsStateCard(
                message:
                    'Unable to load notifications right now. ${notificationsSnapshot.error}',
                icon: Icons.error_outline_rounded,
              );
            }

            if (!notificationsSnapshot.hasData) {
              return const _NotificationsStateCard(
                message: 'Loading notifications from Firebase...',
                icon: Icons.hourglass_top_rounded,
                showLoader: true,
              );
            }

            final List<NotificationRecord> history = notificationsSnapshot
                .data!.docs
                .map(NotificationRecord.fromFirestore)
                .toList(growable: false)
              ..sort((a, b) {
                final DateTime aDate =
                    a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final DateTime bDate =
                    b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bDate.compareTo(aDate);
              });

            final DateTime now = DateTime.now();
            final DateTime startOfToday = DateTime(now.year, now.month, now.day);
            final int sentToday = history
                .where(
                  (item) =>
                      item.status == NotificationDeliveryStatus.sent &&
                      item.createdAt != null &&
                      !item.createdAt!.isBefore(startOfToday),
                )
                .length;
            final int totalAnnouncements = history.length;
            final int drafts = history
                .where((item) => item.status == NotificationDeliveryStatus.draft)
                .length;
            final int pendingDelivery = history
                .where(
                  (item) =>
                      item.status == NotificationDeliveryStatus.scheduled,
                )
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
                          (constraints.maxWidth - ((columns - 1) * spacing)) /
                              columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: <Widget>[
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Sent Today',
                              value: '$sentToday',
                              subtitle: 'Notifications delivered today',
                              icon: Icons.send_rounded,
                              accentColor: AppColors.coolSky,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Total Notifications',
                              value: '$totalAnnouncements',
                              subtitle: 'Live records in Firebase',
                              icon: Icons.campaign_rounded,
                              accentColor: AppColors.aquamarine,
                              animationDelay: const Duration(milliseconds: 80),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Drafts',
                              value: '$drafts',
                              subtitle: 'Saved notification drafts',
                              icon: Icons.drafts_rounded,
                              accentColor: AppColors.jasmine,
                              animationDelay: const Duration(milliseconds: 160),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Pending Delivery',
                              value: '$pendingDelivery',
                              subtitle: 'Scheduled notifications in queue',
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

                      final Widget composeCard = NotificationComposeCard(
                        title: _title,
                        message: _message,
                        selectedRole: _selectedRole,
                        selectedDepartment: _selectedDepartment,
                        selectedPriority: _selectedPriority,
                        departmentOptions: departmentOptions,
                        onTitleChanged: (value) => setState(() => _title = value),
                        onMessageChanged: (value) =>
                            setState(() => _message = value),
                        onRoleChanged: (value) =>
                            setState(() => _selectedRole = value),
                        onDepartmentChanged: (value) =>
                            setState(() => _selectedDepartment = value),
                        onPriorityChanged: (value) =>
                            setState(() => _selectedPriority = value),
                        onSend: _isSending ? () {} : _handleSend,
                      );

                      final Widget historyCard = history.isEmpty
                          ? const _NotificationsEmptyState()
                          : NotificationHistoryList(
                              notifications: history,
                              onView: _handleView,
                              onResend: _handleResend,
                              onDelete: _handleDelete,
                            );

                      if (stacked) {
                        return Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                composeCard,
                                if (_isSending || _isWorking)
                                  const Positioned.fill(
                                    child: _LoadingOverlay(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Stack(
                              children: <Widget>[
                                historyCard,
                                if (_isWorking)
                                  const Positioned.fill(
                                    child: _LoadingOverlay(),
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
                            flex: 3,
                            child: Stack(
                              children: <Widget>[
                                composeCard,
                                if (_isSending || _isWorking)
                                  const Positioned.fill(
                                    child: _LoadingOverlay(),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 4,
                            child: Stack(
                              children: <Widget>[
                                historyCard,
                                if (_isWorking)
                                  const Positioned.fill(
                                    child: _LoadingOverlay(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<String> _buildDepartmentOptions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
  ) {
    final Set<String> departments = <String>{'All departments'};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in userDocs) {
      final Map<String, dynamic> data = doc.data();
      final String department =
          (data['department'] ?? data['branch'] ?? '').toString().trim();
      if (department.isNotEmpty) {
        departments.add(department);
      }
    }

    final List<String> sorted = departments.toList();
    sorted.sort((a, b) {
      if (a == 'All departments') {
        return -1;
      }
      if (b == 'All departments') {
        return 1;
      }
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return sorted;
  }

  Future<void> _handleSend() async {
    if (_title.trim().isEmpty || _message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title and message before sending.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final String senderEmail =
          AdminAuthController.instance.email?.trim().isNotEmpty == true
              ? AdminAuthController.instance.email!.trim()
              : 'admin@interntracker';

      await _firestore.collection('notifications').add(<String, dynamic>{
        'title': _title.trim(),
        'message': _message.trim(),
        'audience': _selectedRole.storageKey,
        'department': _selectedDepartment,
        'priority': _selectedPriority.storageKey,
        'status': 'sent',
        'senderRole': 'admin',
        'senderName': senderEmail,
        'senderEmail': senderEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'sentAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _title = '';
        _message = '';
        _selectedRole = NotificationAudienceRole.allRoles;
        _selectedDepartment = 'All departments';
        _selectedPriority = NotificationPriority.normal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification. $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _handleView(NotificationRecord item) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DialogLine(label: 'Sent By', value: item.senderLabel),
                _DialogLine(label: 'Audience', value: item.audience.label),
                _DialogLine(label: 'Department', value: item.department),
                _DialogLine(label: 'Priority', value: item.priority.label),
                _DialogLine(label: 'Status', value: item.status.label),
                _DialogLine(label: 'Sent Time', value: item.sentTime),
                const SizedBox(height: 12),
                Text(
                  item.message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleResend(NotificationRecord item) async {
    setState(() => _isWorking = true);
    try {
      await _firestore.collection('notifications').doc(item.id).update(
        <String, dynamic>{
          'status': 'sent',
          'sentAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'resentAt': FieldValue.serverTimestamp(),
        },
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resent "${item.title}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend "${item.title}". $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _handleDelete(NotificationRecord item) async {
    setState(() => _isWorking = true);
    try {
      await _firestore.collection('notifications').doc(item.id).delete();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.title}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete "${item.title}". $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
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
                  'Create, resend, review, and delete live notification records from Firebase.',
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

class _NotificationsStateCard extends StatelessWidget {
  const _NotificationsStateCard({
    required this.message,
    required this.icon,
    this.showLoader = false,
  });

  final String message;
  final IconData icon;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 6,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 18),
            if (showLoader) ...<Widget>[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 14),
            ] else ...<Widget>[
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No notifications found',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'The Firebase notifications collection is empty right now. Send a notification to create the first live record.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.66),
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
    );
  }
}

class _DialogLine extends StatelessWidget {
  const _DialogLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
