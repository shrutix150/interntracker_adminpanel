import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

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
    required this.startDateValue,
    required this.endDateValue,
    required this.facultyMentor,
    required this.companyMentor,
    required this.status,
    required this.attendance,
    required this.progress,
    required this.weeklyCheckIns,
    required this.missedLogs,
    required this.rawStatusFields,
    required this.rawProgressFields,
    this.notes,
    this.explicitStatus,
    this.explicitProgress,
    this.completionFlag,
    this.riskFlag,
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
  final DateTime? startDateValue;
  final DateTime? endDateValue;
  final String facultyMentor;
  final String companyMentor;
  final StudentInternshipStatus status;
  final int attendance;
  final int progress;
  final int weeklyCheckIns;
  final int missedLogs;
  final Map<String, dynamic> rawStatusFields;
  final Map<String, dynamic> rawProgressFields;
  final String? notes;
  final StudentInternshipStatus? explicitStatus;
  final int? explicitProgress;
  final bool? completionFlag;
  final bool? riskFlag;
  final bool isDeleted;
  final DateTime? deletedAt;

  bool get isValidRecord {
    final bool hasName =
        name.trim().isNotEmpty && name.trim() != 'Unnamed Student';
    final bool hasEmail = email.trim().isNotEmpty;
    final bool hasRoll =
        rollNumber.trim().isNotEmpty && rollNumber.trim().toLowerCase() != 'n/a';
    return hasName || hasEmail || hasRoll;
  }

  bool get needsAttention => StudentDataResolver.isAttentionNeeded(
        attendance: attendance,
        missedLogs: missedLogs,
        riskFlag: riskFlag,
      );

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
    DateTime? startDateValue,
    DateTime? endDateValue,
    String? facultyMentor,
    String? companyMentor,
    StudentInternshipStatus? status,
    int? attendance,
    int? progress,
    int? weeklyCheckIns,
    int? missedLogs,
    Map<String, dynamic>? rawStatusFields,
    Map<String, dynamic>? rawProgressFields,
    String? notes,
    Object? explicitStatus = _sentinel,
    Object? explicitProgress = _sentinel,
    Object? completionFlag = _sentinel,
    Object? riskFlag = _sentinel,
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
      startDateValue: startDateValue ?? this.startDateValue,
      endDateValue: endDateValue ?? this.endDateValue,
      facultyMentor: facultyMentor ?? this.facultyMentor,
      companyMentor: companyMentor ?? this.companyMentor,
      status: status ?? this.status,
      attendance: attendance ?? this.attendance,
      progress: progress ?? this.progress,
      weeklyCheckIns: weeklyCheckIns ?? this.weeklyCheckIns,
      missedLogs: missedLogs ?? this.missedLogs,
      rawStatusFields: rawStatusFields ?? this.rawStatusFields,
      rawProgressFields: rawProgressFields ?? this.rawProgressFields,
      notes: notes ?? this.notes,
      explicitStatus: explicitStatus == _sentinel
          ? this.explicitStatus
          : explicitStatus as StudentInternshipStatus?,
      explicitProgress: explicitProgress == _sentinel
          ? this.explicitProgress
          : explicitProgress as int?,
      completionFlag: completionFlag == _sentinel
          ? this.completionFlag
          : completionFlag as bool?,
      riskFlag:
          riskFlag == _sentinel ? this.riskFlag : riskFlag as bool?,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory StudentRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final DateTime? startDateValue = _readInternshipDate(<dynamic>[
      data['startDate'],
      data['internshipStartDate'],
      data['startsOn'],
      data['start_date'],
      data['internshipStart'],
      data['internship'] is Map ? data['internship']['startDate'] : null,
      data['internship'] is Map ? data['internship']['start_date'] : null,
      data['timeline'] is Map ? data['timeline']['startDate'] : null,
      data['timeline'] is Map ? data['timeline']['start'] : null,
      data['dates'] is Map ? data['dates']['startDate'] : null,
      data['dates'] is Map ? data['dates']['start'] : null,
    ]);
    final DateTime? endDateValue = _readInternshipDate(<dynamic>[
      data['endDate'],
      data['internshipEndDate'],
      data['endsOn'],
      data['end_date'],
      data['internshipEnd'],
      data['internship'] is Map ? data['internship']['endDate'] : null,
      data['internship'] is Map ? data['internship']['end_date'] : null,
      data['timeline'] is Map ? data['timeline']['endDate'] : null,
      data['timeline'] is Map ? data['timeline']['end'] : null,
      data['dates'] is Map ? data['dates']['endDate'] : null,
      data['dates'] is Map ? data['dates']['end'] : null,
    ]);

    final Map<String, dynamic> rawStatusFields = <String, dynamic>{
      'internshipStatus': data['internshipStatus'],
      'status': data['status'],
      'internshipState': data['internshipState'],
      'internship_status': data['internship_status'],
      'reviewStatus': data['reviewStatus'],
      'completionStatus': data['completionStatus'],
      'warningStatus': data['warningStatus'],
    }..removeWhere((_, value) => value == null);

    final Map<String, dynamic> rawProgressFields = <String, dynamic>{
      'progress': data['progress'],
      'progressPercentage': data['progressPercentage'],
      'progressPercent': data['progressPercent'],
      'completion': data['completion'],
      'completionPercentage': data['completionPercentage'],
      'stats.progress': data['stats'] is Map ? data['stats']['progress'] : null,
    }..removeWhere((_, value) => value == null);

    final int? explicitProgress = _readFirstIntNullable(rawProgressFields.values);
    final int attendance = StudentDataResolver.clampPercent(
      _readFirstIntNullable(<dynamic>[
            data['attendance'],
            data['attendancePercentage'],
            data['attendancePercent'],
            data['overallAttendance'],
            data['attendanceRate'],
            data['attendance_rate'],
            data['stats'] is Map ? data['stats']['attendance'] : null,
          ]) ??
          0,
    );
    final int weeklyCheckIns = StudentDataResolver.clampCount(
      _readFirstIntNullable(<dynamic>[
            data['weeklyCheckIns'],
            data['weeklyCheckIn'],
            data['weeklyCheckin'],
            data['checkIns'],
            data['checkInCount'],
            data['stats'] is Map ? data['stats']['weeklyCheckIns'] : null,
          ]) ??
          0,
    );
    final int missedLogs = StudentDataResolver.clampCount(
      _readFirstIntNullable(<dynamic>[
            data['missedLogs'],
            data['missedLogCount'],
            data['missedCheckIns'],
            data['pendingLogs'],
            data['stats'] is Map ? data['stats']['missedLogs'] : null,
          ]) ??
          0,
    );
    final bool? completionFlag = _readCompletionFlag(data);
    final bool? riskFlag = _readRiskFlag(data);

    final int resolvedProgress = StudentDataResolver.resolveStudentProgress(
      explicitProgress: explicitProgress,
      completionFlag: completionFlag,
      startDate: startDateValue,
      endDate: endDateValue,
      weeklyCheckIns: weeklyCheckIns,
    );

    final StudentInternshipStatus resolvedStatus =
        StudentDataResolver.resolveDateBasedStatus(
      startDate: startDateValue,
      endDate: endDateValue,
      fallbackStatus: StudentInternshipStatus.pending,
    );

    return StudentRecord(
      id: doc.id,
      name: _readString(data['name'] ?? data['fullName'], 'Unnamed Student'),
      email: _readString(data['email']),
      rollNumber: _readRollNumber(data, doc.id),
      department: _readString(data['department'] ?? data['dept'], 'Unassigned'),
      year: StudentYear.fromFirestore(data['year']),
      company: _readString(
        data['companyName'] ?? data['company'],
        'Not Assigned',
      ),
      internshipRole: _readString(
        data['internshipRole'] ?? data['roleTitle'],
        'Intern',
      ),
      duration: _readString(data['duration'], 'Not specified'),
      startDate: _formatDate(startDateValue),
      endDate: _formatDate(endDateValue),
      startDateValue: startDateValue,
      endDateValue: endDateValue,
      facultyMentor: _readPersonLike(<dynamic>[
        data['collegeMentor'],
        data['collegeMentorName'],
        data['assignedFaculty'],
        data['assignedFacultyName'],
        data['facultyMentor'],
        data['facultyMentorName'],
        data['facultyName'],
        data['mentorFaculty'],
      ], 'Not Assigned'),
      companyMentor: _readPersonLike(<dynamic>[
        data['assignedMentor'],
        data['assignedMentorName'],
        data['companyMentor'],
        data['companyMentorName'],
        data['mentor'],
        data['mentorName'],
        data['guideName'],
        data['industryMentor'],
      ], 'Not Assigned'),
      status: resolvedStatus,
      attendance: attendance,
      progress: resolvedProgress,
      weeklyCheckIns: weeklyCheckIns,
      missedLogs: missedLogs,
      rawStatusFields: rawStatusFields,
      rawProgressFields: rawProgressFields,
      notes: _readNullableString(data['notes'] ?? data['remarks']),
      explicitStatus: null,
      explicitProgress: explicitProgress,
      completionFlag: completionFlag,
      riskFlag: riskFlag,
      isDeleted: data['isDeleted'] == true,
      deletedAt: data['deletedAt'] is Timestamp
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  StudentRecord computeStudentMetrics({
    int? attendance,
    int? weeklyCheckIns,
    int? missedLogs,
    int? attendanceDerivedProgress,
    int? taskDerivedProgress,
  }) {
    final int resolvedAttendance =
        StudentDataResolver.clampPercent(attendance ?? this.attendance);
    final int resolvedWeeklyCheckIns =
        StudentDataResolver.clampCount(weeklyCheckIns ?? this.weeklyCheckIns);
    final int resolvedMissedLogs =
        StudentDataResolver.clampCount(missedLogs ?? this.missedLogs);
    final int resolvedProgress = StudentDataResolver.resolveStudentProgress(
      explicitProgress: explicitProgress,
      attendanceDerivedProgress: attendanceDerivedProgress,
      taskDerivedProgress: taskDerivedProgress,
      completionFlag: completionFlag,
      startDate: startDateValue,
      endDate: endDateValue,
      weeklyCheckIns: resolvedWeeklyCheckIns,
    );
    final StudentInternshipStatus resolvedStatus =
        StudentDataResolver.resolveDateBasedStatus(
      startDate: startDateValue,
      endDate: endDateValue,
      fallbackStatus: StudentInternshipStatus.pending,
    );

    return copyWith(
      attendance: resolvedAttendance,
      weeklyCheckIns: resolvedWeeklyCheckIns,
      missedLogs: resolvedMissedLogs,
      progress: resolvedProgress,
      status: resolvedStatus,
    );
  }

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static const Object _sentinel = Object();

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
              value['collegeMentorName'] ??
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

  static int? _readIntNullable(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static int? _readFirstIntNullable(Iterable<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }
      final int? parsed = _readIntNullable(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static DateTime? _readInternshipDate(Iterable<dynamic> values) {
    for (final dynamic value in values) {
      final DateTime? parsed = StudentDataResolver.parseInternshipDate(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static bool? _readCompletionFlag(Map<String, dynamic> data) {
    return _readBool(<dynamic>[
      data['isCompleted'],
      data['completed'],
      data['internshipCompleted'],
      data['completionFlag'],
      data['completion_status'],
      data['completionStatus'],
    ]);
  }

  static bool? _readRiskFlag(Map<String, dynamic> data) {
    return _readBool(<dynamic>[
      data['isAtRisk'],
      data['atRisk'],
      data['riskFlag'],
      data['needsAttention'],
      data['warning'],
      data['hasIssue'],
    ]);
  }

  static bool? _readBool(Iterable<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final String normalized = value.trim().toLowerCase();
        if (<String>{'true', 'yes', '1', 'completed', 'done', 'risk'}
            .contains(normalized)) {
          return true;
        }
        if (<String>{'false', 'no', '0', 'pending', 'active'}
            .contains(normalized)) {
          return false;
        }
      }
    }
    return null;
  }

  static String _formatDate(DateTime? date) {
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

class StudentDataResolver {
  const StudentDataResolver._();

  static const int atRiskAttendanceThreshold = 75;
  static const int atRiskMissedLogsThreshold = 3;

  static DateTime? parseInternshipDate(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is Timestamp) {
      return _normalizeDate(raw.toDate());
    }
    if (raw is DateTime) {
      return _normalizeDate(raw);
    }
    if (raw is! String) {
      return null;
    }

    final String value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final DateTime? isoDate = DateTime.tryParse(value);
    if (isoDate != null) {
      return _normalizeDate(isoDate);
    }

    final RegExp numericPattern =
        RegExp(r'^(\d{1,2})[\/-](\d{1,2})[\/-](\d{2,4})$');
    final Match? numericMatch = numericPattern.firstMatch(value);
    if (numericMatch != null) {
      final int first = int.parse(numericMatch.group(1)!);
      final int second = int.parse(numericMatch.group(2)!);
      int year = int.parse(numericMatch.group(3)!);
      if (year < 100) {
        year += 2000;
      }
      if (first > 12) {
        return _safeDate(year, second, first);
      }
      if (second > 12) {
        return _safeDate(year, first, second);
      }
      return _safeDate(year, first, second);
    }

    final RegExp namedMonthPattern =
        RegExp(r'^(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})$');
    final Match? namedMonthMatch = namedMonthPattern.firstMatch(value);
    if (namedMonthMatch != null) {
      final int day = int.parse(namedMonthMatch.group(1)!);
      final int? month = _monthFromName(namedMonthMatch.group(2)!);
      final int year = int.parse(namedMonthMatch.group(3)!);
      if (month == null) {
        return null;
      }
      return _safeDate(year, month, day);
    }

    return null;
  }

  static StudentInternshipStatus resolveDateBasedStatus({
    required DateTime? startDate,
    required DateTime? endDate,
    StudentInternshipStatus fallbackStatus = StudentInternshipStatus.pending,
    DateTime? today,
  }) {
    final DateTime referenceDate = dateOnly(today ?? DateTime.now());
    final DateTime? normalizedStart =
        startDate == null ? null : dateOnly(startDate);
    final DateTime? normalizedEnd = endDate == null ? null : dateOnly(endDate);

    if (normalizedStart == null || normalizedEnd == null) {
      return fallbackStatus;
    }
    if (normalizedEnd.isBefore(referenceDate)) {
      return StudentInternshipStatus.completed;
    }
    if ((normalizedStart.isBefore(referenceDate) ||
            normalizedStart.isAtSameMomentAs(referenceDate)) &&
        (normalizedEnd.isAfter(referenceDate) ||
            normalizedEnd.isAtSameMomentAs(referenceDate))) {
      return StudentInternshipStatus.active;
    }
    if (normalizedStart.isAfter(referenceDate)) {
      return StudentInternshipStatus.pending;
    }
    return fallbackStatus;
  }

  static int resolveStudentProgress({
    int? explicitProgress,
    int? attendanceDerivedProgress,
    int? taskDerivedProgress,
    bool? completionFlag,
    DateTime? startDate,
    DateTime? endDate,
    int weeklyCheckIns = 0,
    DateTime? today,
  }) {
    final int? timelineProgress = resolveTimelineProgress(
      startDate: startDate,
      endDate: endDate,
      today: today ?? DateTime.now(),
    );
    if (timelineProgress != null) {
      return timelineProgress;
    }

    final int? fallbackProgress = _firstNonNullInt(<int?>[
      explicitProgress,
      attendanceDerivedProgress,
      taskDerivedProgress,
    ]);
    if (fallbackProgress != null) {
      return clampPercent(fallbackProgress);
    }
    if (completionFlag == true) {
      return 100;
    }
    return 0;
  }

  static int? resolveTimelineProgress({
    required DateTime? startDate,
    required DateTime? endDate,
    required DateTime today,
  }) {
    final DateTime? normalizedStart =
        startDate == null ? null : dateOnly(startDate);
    final DateTime? normalizedEnd = endDate == null ? null : dateOnly(endDate);
    final DateTime normalizedToday = dateOnly(today);

    if (normalizedStart == null || normalizedEnd == null) {
      return null;
    }
    if (normalizedEnd.isBefore(normalizedStart)) {
      return null;
    }
    if (normalizedToday.isBefore(normalizedStart)) {
      return 0;
    }
    if (normalizedToday.isAfter(normalizedEnd)) {
      return 100;
    }

    final int totalDays = normalizedEnd.difference(normalizedStart).inDays;
    if (totalDays <= 0) {
      return 100;
    }
    final int elapsedDays = normalizedToday.difference(normalizedStart).inDays;
    final double progressPercent = (elapsedDays / totalDays) * 100;
    return clampPercent(progressPercent.round());
  }

  static bool isAttentionNeeded({
    required int attendance,
    required int missedLogs,
    required bool? riskFlag,
  }) {
    return riskFlag == true ||
        (attendance > 0 && attendance < atRiskAttendanceThreshold) ||
        missedLogs >= atRiskMissedLogsThreshold;
  }

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int clampPercent(int value) => value.clamp(0, 100);

  static int clampCount(int value) => value < 0 ? 0 : value;

  static DateTime? _safeDate(int year, int month, int day) {
    try {
      return _normalizeDate(DateTime(year, month, day));
    } catch (_) {
      return null;
    }
  }

  static DateTime _normalizeDate(DateTime value) => dateOnly(value.toLocal());

  static int? _monthFromName(String rawMonth) {
    const Map<String, int> months = <String, int>{
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'sept': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return months[rawMonth.trim().toLowerCase()];
  }

  static int? _firstNonNullInt(Iterable<int?> values) {
    for (final int? value in values) {
      if (value != null) {
        return value;
      }
    }
    return null;
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
}
