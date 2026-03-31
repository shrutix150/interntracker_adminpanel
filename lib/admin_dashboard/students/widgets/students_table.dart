import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class StudentsTable extends StatelessWidget {
  const StudentsTable({
    super.key,
    required this.students,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final List<StudentRecord> students;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

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
          final bool compact = constraints.maxWidth < 1080;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: students
                  .map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StudentCard(
                        student: student,
                        onView: onView,
                        onEdit: onEdit,
                        onMessage: onMessage,
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          }

          return Column(
            children: <Widget>[
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
                    _HeaderCell(label: 'Student', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Department', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Year', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Company', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Faculty Mentor', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Attendance', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Progress', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentRow(
                    student: student,
                    onView: onView,
                    onEdit: onEdit,
                    onMessage: onMessage,
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

class _StudentRow extends StatefulWidget {
  const _StudentRow({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.hover : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? AppColors.coolSky.withOpacity(0.18)
                : AppColors.border,
          ),
          boxShadow: _hovered
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
            Expanded(flex: 3, child: _StudentIdentity(student: widget.student)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.department)),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _BodyText(widget.student.year.label)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.company)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.facultyMentor)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.student.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _BodyText('${widget.student.attendance}%'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _ProgressCell(progress: widget.student.progress),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _ActionGroup(
                student: widget.student,
                onView: widget.onView,
                onEdit: widget.onEdit,
                onMessage: widget.onMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatefulWidget {
  const _StudentCard({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.hover : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
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
                Expanded(child: _StudentIdentity(student: widget.student)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.student.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(
              label: 'Department',
              value: widget.student.department,
            ),
            _CompactInfoRow(label: 'Year', value: widget.student.year.label),
            _CompactInfoRow(label: 'Company', value: widget.student.company),
            _CompactInfoRow(
              label: 'Faculty Mentor',
              value: widget.student.facultyMentor,
            ),
            _CompactInfoRow(
              label: 'Attendance',
              value: '${widget.student.attendance}%',
            ),
            const SizedBox(height: 8),
            _ProgressCell(progress: widget.student.progress),
            const SizedBox(height: 16),
            _ActionGroup(
              student: widget.student,
              onView: widget.onView,
              onEdit: widget.onEdit,
              onMessage: widget.onMessage,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.student});

  final StudentRecord student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: student.status.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            student.initials,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                student.name,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                '${student.rollNumber} | ${student.email}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
      style: AppTextStyles.tableCell.copyWith(
        color: AppColors.textPrimary,
        height: 1.35,
      ),
    );
  }
}

class _ProgressCell extends StatelessWidget {
  const _ProgressCell({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final Color barColor = progress >= 80
        ? AppColors.aquamarine
        : progress >= 60
        ? AppColors.coolSky
        : AppColors.tangerineDream;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$progress%',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
    this.compact = false,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;
  final bool compact;

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
          compact: compact,
          onTap: () => onView(student),
        ),
        _ActionButton(
          label: 'Edit',
          icon: Icons.edit_rounded,
          color: AppColors.jasmine,
          compact: compact,
          onTap: () => onEdit(student),
        ),
        _ActionButton(
          label: 'Delete',
          icon: Icons.delete_outline,
          color: AppColors.strawberryRed,
          compact: compact,
          onTap: () => onMessage(student),
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
    required this.compact,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 12,
            vertical: compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: compact ? 15 : 16, color: AppColors.textPrimary),
              SizedBox(width: compact ? 6 : 8),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StudentInternshipStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.16)),
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

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.year,
    required this.company,
    required this.internshipRole,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.facultyMentor,
    required this.companyMentor,
    required this.status,
    required this.attendance,
    required this.progress,
    required this.weeklyCheckIns,
    required this.missedLogs,
    this.notes,
    this.isDeleted = false,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String email;
  final String rollNumber;
  final String department;
  final StudentYear year;
  final String company;
  final String internshipRole;
  final String duration;
  final String startDate;
  final String endDate;
  final String facultyMentor;
  final String companyMentor;
  final StudentInternshipStatus status;
  final int attendance;
  final int progress;
  final int weeklyCheckIns;
  final int missedLogs;
  final String? notes;
  final bool isDeleted;
  final DateTime? deletedAt;

  StudentRecord copyWith({
    String? id,
    String? name,
    String? email,
    String? rollNumber,
    String? department,
    StudentYear? year,
    String? company,
    String? internshipRole,
    String? duration,
    String? startDate,
    String? endDate,
    String? facultyMentor,
    String? companyMentor,
    StudentInternshipStatus? status,
    int? attendance,
    int? progress,
    int? weeklyCheckIns,
    int? missedLogs,
    String? notes,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return StudentRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      year: year ?? this.year,
      company: company ?? this.company,
      internshipRole: internshipRole ?? this.internshipRole,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      facultyMentor: facultyMentor ?? this.facultyMentor,
      companyMentor: companyMentor ?? this.companyMentor,
      status: status ?? this.status,
      attendance: attendance ?? this.attendance,
      progress: progress ?? this.progress,
      weeklyCheckIns: weeklyCheckIns ?? this.weeklyCheckIns,
      missedLogs: missedLogs ?? this.missedLogs,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory StudentRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();

    return StudentRecord(
      id: doc.id,
      name: _readString(data['name'] ?? data['fullName'], 'Unnamed Student'),
      email: _readString(data['email']),
      rollNumber: _readRollNumber(data, doc.id),
      department: _readString(data['department'] ?? data['dept'], 'Unassigned'),
      year: StudentYear.fromFirestore(data['year']),
      company: _readString(data['companyName'] ?? data['company'], 'Not Assigned'),
      internshipRole: _readString(
        data['internshipRole'] ?? data['roleTitle'],
        'Intern',
      ),
      duration: _readString(data['duration'], 'Not specified'),
      startDate: _formatDate(data['startDate']),
      endDate: _formatDate(data['endDate']),
      facultyMentor: _readPersonLike(
        <dynamic>[
          data['assignedFaculty'],
          data['assignedFacultyName'],
          data['facultyMentor'],
          data['facultyMentorName'],
          data['facultyName'],
          data['mentorFaculty'],
        ],
        'Not Assigned',
      ),
      companyMentor: _readPersonLike(
        <dynamic>[
          data['assignedMentor'],
          data['assignedMentorName'],
          data['companyMentor'],
          data['companyMentorName'],
          data['mentor'],
          data['mentorName'],
          data['guideName'],
          data['industryMentor'],
        ],
        'Not Assigned',
      ),
      status: StudentInternshipStatus.fromFirestore(
        data['internshipStatus'] ?? data['status'],
      ),
      attendance: _readFirstInt(
        <dynamic>[
          data['attendance'],
          data['attendancePercentage'],
          data['attendancePercent'],
          data['overallAttendance'],
          data['attendanceRate'],
          data['attendance_rate'],
          data['stats'] is Map ? data['stats']['attendance'] : null,
        ],
        fallback: 0,
      ),
      progress: _readFirstInt(
        <dynamic>[
          data['progress'],
          data['progressPercentage'],
          data['progressPercent'],
          data['completion'],
          data['completionPercentage'],
          data['stats'] is Map ? data['stats']['progress'] : null,
        ],
        fallback: 0,
      ),
      weeklyCheckIns: _readFirstInt(
        <dynamic>[
          data['weeklyCheckIns'],
          data['weeklyCheckIn'],
          data['weeklyCheckin'],
          data['checkIns'],
          data['checkInCount'],
          data['stats'] is Map ? data['stats']['weeklyCheckIns'] : null,
        ],
        fallback: 0,
      ),
      missedLogs: _readFirstInt(
        <dynamic>[
          data['missedLogs'],
          data['missedLogCount'],
          data['missedCheckIns'],
          data['pendingLogs'],
          data['stats'] is Map ? data['stats']['missedLogs'] : null,
        ],
        fallback: 0,
      ),
      notes: _readNullableString(data['notes'] ?? data['remarks']),
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] is Timestamp ? (data['deletedAt'] as Timestamp).toDate() : null,
    );
  }

  String get initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String _readString(dynamic value, [String fallback = '']) {
    if (value == null) {
      return fallback;
    }
    final String normalized = value.toString().trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static String _readRollNumber(Map<String, dynamic> data, String docId) {
    final String explicit = _readString(
      data['rollNumber'] ??
          data['rollNo'] ??
          data['studentId'] ??
          data['studentCode'] ??
          data['enrollmentNumber'] ??
          data['enrollmentNo'] ??
          data['registrationNumber'] ??
          data['registrationNo'] ??
          data['prn'],
    );
    if (explicit.isNotEmpty) {
      return explicit;
    }

    final String normalizedDocId = docId.trim();
    if (RegExp(r'^\d{4,}$').hasMatch(normalizedDocId)) {
      return normalizedDocId;
    }

    return 'N/A';
  }

  static String _readPersonLike(List<dynamic> values, [String fallback = '']) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }

      if (value is Map) {
        final String fromMap = _readString(
          value['name'] ??
              value['fullName'] ??
              value['displayName'] ??
              value['mentorName'] ??
              value['facultyName'] ??
              value['email'],
        );
        if (fromMap.isNotEmpty) {
          return fromMap;
        }
      }

      final String normalized = _readString(value);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return fallback;
  }

  static String? _readNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static int _readFirstInt(List<dynamic> values, {int fallback = 0}) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }

      final int parsed = _readInt(value, fallback: fallback);
      if (parsed != fallback || value.toString().trim() == '$fallback') {
        return parsed;
      }
    }
    return fallback;
  }

  static String _formatDate(dynamic value) {
    DateTime? date;
    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return 'Not set';
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

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}

enum StudentYear {
  firstYear('1st Year'),
  secondYear('2nd Year'),
  thirdYear('3rd Year'),
  fourthYear('4th Year');

  const StudentYear(this.label);

  final String label;

  factory StudentYear.fromFirestore(dynamic value) {
    final String normalized = (value ?? '').toString().toLowerCase().trim();
    switch (normalized) {
      case '1':
      case '1st year':
      case 'first':
      case 'firstyear':
      case 'first year':
        return StudentYear.firstYear;
      case '2':
      case '2nd year':
      case 'second':
      case 'secondyear':
      case 'second year':
        return StudentYear.secondYear;
      case '4':
      case '4th year':
      case 'fourth':
      case 'final':
      case 'fourthyear':
      case 'fourth year':
        return StudentYear.fourthYear;
      default:
        return StudentYear.thirdYear;
    }
  }
}

enum StudentInternshipStatus {
  active(
    label: 'Active',
    color: AppColors.coolSky,
    backgroundColor: AppColors.primarySoft,
  ),
  completed(
    label: 'Completed',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  pending(
    label: 'Pending',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  ),
  atRisk(
    label: 'At Risk',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  );

  const StudentInternshipStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  factory StudentInternshipStatus.fromFirestore(dynamic value) {
    final String normalized = (value ?? '').toString().toLowerCase().trim();
    switch (normalized) {
      case 'active':
      case 'ongoing':
        return StudentInternshipStatus.active;
      case 'completed':
      case 'done':
        return StudentInternshipStatus.completed;
      case 'atrisk':
      case 'at risk':
      case 'risk':
        return StudentInternshipStatus.atRisk;
      default:
        return StudentInternshipStatus.pending;
    }
  }
}
