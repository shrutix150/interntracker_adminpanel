import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'widgets/dashboard_chart_card.dart';
import 'widgets/recent_activity_table.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalStudents,
    required this.totalFaculty,
    required this.pendingApprovals,
    required this.totalCompanies,
    required this.activeInternships,
  });

  final int totalStudents;
  final int totalFaculty;
  final int pendingApprovals;
  final int totalCompanies;
  final int activeInternships;
}

class DashboardOverview {
  const DashboardOverview({
    required this.stats,
    required this.activeThisWeek,
    required this.approvalTurnaroundLabel,
    required this.lineChartData,
    required this.donutChartData,
    required this.activities,
    required this.approvalRate,
    required this.approvedStudents,
    required this.pendingStudents,
  });

  final DashboardStats stats;
  final int activeThisWeek;
  final String approvalTurnaroundLabel;
  final DashboardLineChartData lineChartData;
  final DashboardDonutChartData donutChartData;
  final List<ActivityItem> activities;
  final int approvalRate;
  final int approvedStudents;
  final int pendingStudents;
}

class DashboardController {
  DashboardController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<DashboardOverview> watchOverview() {
    return _firestore.collection('user').snapshots().asyncMap((snapshot) async {
      final int pendingApprovals = (await _firestore
              .collection('user')
              .where('isApproved', isEqualTo: false)
              .get())
          .docs
          .length;
      int totalStudents = 0;
      int totalFaculty = 0;
      final int totalCompanies =
          (await _firestore.collection('company').get()).docs.length;
      int activeInternships = 0;
      int completedInternships = 0;
      int pendingInternships = 0;
      int approvedStudents = 0;
      int pendingStudents = 0;
      int activeThisWeek = 0;

      final DateTime now = DateTime.now();
      final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
      final List<_DashboardUserSnapshot> users = snapshot.docs
          .map(_DashboardUserSnapshot.tryFromFirestore)
          .whereType<_DashboardUserSnapshot>()
          .toList(growable: false);

      for (final _DashboardUserSnapshot user in users) {
        final bool isStudent = user.role == 'student';

        if (isStudent) {
          totalStudents++;
          if (user.isApproved) {
            approvedStudents++;
          } else {
            pendingStudents++;
          }
        }

        if (user.role == 'faculty') {
          totalFaculty++;
        }

        switch (user.internshipStatus) {
          case 'ongoing':
            activeInternships++;
            break;
          case 'completed':
            completedInternships++;
            break;
          default:
            pendingInternships++;
            break;
        }

        if (user.internshipStatus == 'ongoing' &&
            user.isActiveDuringWeek(startOfWeek, endOfWeek)) {
          activeThisWeek++;
        }
      }

      final DashboardStats stats = DashboardStats(
        totalStudents: totalStudents,
        totalFaculty: totalFaculty,
        pendingApprovals: pendingApprovals,
        totalCompanies: totalCompanies,
        activeInternships: activeInternships,
      );

      final int approvalRate = totalStudents == 0
          ? 0
          : ((approvedStudents / totalStudents) * 100).round();

      final List<ActivityItem> activities = _buildActivities(users, now);
      debugPrint('Dashboard overview fetched ${snapshot.docs.length} user docs');
      debugPrint('Dashboard raw doc sample: ${snapshot.docs.take(3).map((doc) => doc.data()).toList()}');
      debugPrint('Dashboard metric counts: totalStudents=$totalStudents, totalFaculty=$totalFaculty, pendingApprovals=$pendingApprovals, totalCompanies=$totalCompanies, activeInternships=$activeInternships, activeThisWeek=$activeThisWeek, approvedStudents=$approvedStudents, pendingStudents=$pendingStudents');
      debugPrint('Recent activity item count: ${activities.length}');

      return DashboardOverview(
        stats: stats,
        activeThisWeek: activeThisWeek,
        approvalTurnaroundLabel: '$pendingApprovals awaiting review',
        lineChartData: _buildLineChart(users, now),
        donutChartData: DashboardDonutChartData(
          sections: <DashboardDonutSectionData>[
            DashboardDonutSectionData(
              label: 'Active',
              value: activeInternships,
              color: AppColors.coolSky,
            ),
            DashboardDonutSectionData(
              label: 'Completed',
              value: completedInternships,
              color: AppColors.aquamarine,
            ),
            DashboardDonutSectionData(
              label: 'Pending',
              value: pendingInternships,
              color: AppColors.tangerineDream,
            ),
          ],
        ),
        activities: activities,
        approvalRate: approvalRate,
        approvedStudents: approvedStudents,
        pendingStudents: pendingStudents,
      );
    });
  }

  DashboardLineChartData _buildLineChart(
    List<_DashboardUserSnapshot> users,
    DateTime now,
  ) {
    final List<DateTime> months = List<DateTime>.generate(6, (int index) {
      return DateTime(now.year, now.month - (5 - index), 1);
    });

    const List<String> monthLabels = <String>[
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

    final List<int> counts = List<int>.filled(months.length, 0);

    for (final _DashboardUserSnapshot user in users) {
      if (user.role != 'student' || user.createdAt == null) {
        continue;
      }

      for (int index = 0; index < months.length; index++) {
        final DateTime bucket = months[index];
        if (user.createdAt!.year == bucket.year &&
            user.createdAt!.month == bucket.month) {
          counts[index]++;
          break;
        }
      }
    }

    return DashboardLineChartData(
      points: List<DashboardLinePoint>.generate(months.length, (int index) {
        final DateTime month = months[index];
        return DashboardLinePoint(
          label: monthLabels[month.month - 1],
          value: counts[index].toDouble(),
        );
      }),
    );
  }

  List<ActivityItem> _buildActivities(
    List<_DashboardUserSnapshot> users,
    DateTime now,
  ) {
    final List<_DashboardUserSnapshot> sorted = users.toList()
      ..sort((a, b) {
        final DateTime aTime = a.lastActivityAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bTime = b.lastActivityAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    return sorted.take(5).map((user) {
      final String entity = user.name.isEmpty ? 'Unknown User' : user.name;
      final String roleLabel = _roleLabel(user.role);
      final ActivityStatus status = _activityStatus(user);

      final DateTime? activityTime = user.lastActivityAt ?? user.createdAt;
      return ActivityItem(
        entity: entity,
        action: _activityAction(user),
        role: roleLabel,
        time: _timeAgo(activityTime, now),
        status: status,
        initials: _initials(entity),
        accentColor: _accentForRole(user.role),
      );
    }).toList(growable: false);
  }

  ActivityStatus _activityStatus(_DashboardUserSnapshot user) {
    if (!user.isApproved) {
      return ActivityStatus.pending;
    }
    if (user.status == 'approved') {
      return ActivityStatus.approved;
    }
    if (user.internshipStatus == 'ongoing') {
      return ActivityStatus.updated;
    }
    return ActivityStatus.review;
  }

  String _activityAction(_DashboardUserSnapshot user) {
    if (!user.isApproved) {
      return 'Submitted account approval request';
    }
    if (user.role == 'student' && user.isApproved) {
      if (user.internshipStatus == 'ongoing') {
        return 'Student internship active';
      }
      if (user.internshipStatus == 'completed') {
        return 'Student internship completed';
      }
      return 'Student profile updated';
    }
    if (user.role == 'mentor' && user.isApproved) {
      return 'Mentor account approved';
    }
    if (user.role == 'faculty' && user.isApproved) {
      return 'Faculty account approved';
    }
    return 'User profile updated in the system';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'faculty':
        return 'Faculty';
      case 'mentor':
        return 'Mentor';
      default:
        return 'User';
    }
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'faculty':
        return AppColors.aquamarine;
      case 'mentor':
        return AppColors.tangerineDream;
      default:
        return AppColors.coolSky;
    }
  }

  String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _timeAgo(DateTime? date, DateTime now) {
    if (date == null) {
      return 'Recently';
    }

    final Duration difference = now.difference(date);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hrs ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DashboardUserSnapshot {
  const _DashboardUserSnapshot({
    required this.name,
    required this.role,
    required this.isApproved,
    required this.status,
    required this.internshipStatus,
    required this.createdAt,
    required this.lastActivityAt,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final String role;
  final bool isApproved;
  final String status;
  final String internshipStatus;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final DateTime? startDate;
  final DateTime? endDate;

  factory _DashboardUserSnapshot.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();

    return _DashboardUserSnapshot(
      name: _readString(data['name'] ?? data['fullName']),
      role: _readString(data['role']).toLowerCase(),
      isApproved: _readBool(data['isApproved']),
      status: _readString(data['status']).toLowerCase(),
      internshipStatus: _readString(
        data['internshipStatus'] ?? 'pending',
      ).toLowerCase(),
      createdAt: _readDateTime(data['createdAt']),
      startDate: _readDateTime(data['startDate']),
      endDate: _readDateTime(data['endDate']),
      lastActivityAt: _readDateTime(data['updatedAt']) ?? _readDateTime(data['createdAt']),
    );
  }

  static _DashboardUserSnapshot? tryFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return _DashboardUserSnapshot.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool isActiveDuringWeek(DateTime startOfWeek, DateTime endOfWeek) {
    final DateTime? start = startDate ?? createdAt;
    if (start == null) {
      return false;
    }

    final bool startsOnOrBeforeWeekEnd = !start.isAfter(endOfWeek);
    final bool endsOnOrAfterWeekStart =
        endDate == null || !endDate!.isBefore(startOfWeek);

    return startsOnOrBeforeWeekEnd && endsOnOrAfterWeekStart;
  }

  static String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final String normalized = value.toLowerCase().trim();
      return normalized == 'true' ||
          normalized == 'approved' ||
          normalized == 'yes';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}
