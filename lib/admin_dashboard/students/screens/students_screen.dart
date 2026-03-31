import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'student_detail_screen.dart';
import '../widgets/attendance_overview_card.dart';
import '../widgets/student_filter_bar.dart';
import '../widgets/student_summary_card.dart';
import '../widgets/students_table.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<StudentRecord>> _studentsStream = _watchStudents();

  String? _selectedDepartment;
  StudentYear? _selectedYear;
  StudentInternshipStatus? _selectedStatus;
  String _searchQuery = '';
  StudentRecord? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudentRecord>>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StudentsStateCard(
            message: 'Unable to load students right now. ${snapshot.error}',
            icon: Icons.error_outline_rounded,
          );
        }

        if (!snapshot.hasData) {
          return const _StudentsStateCard(
            message: 'Loading students from Firebase...',
            icon: Icons.hourglass_top_rounded,
            showLoader: true,
          );
        }

        final List<StudentRecord> students = snapshot.data!;
        final List<StudentRecord> filteredStudents = _filterStudents(students);
        final List<String> departmentOptions = students
            .map((student) => student.department.trim())
            .where((department) => department.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        _syncSelection(students);

        final int totalStudents = students.length;
        final int activeInternships = students
            .where((student) => student.status == StudentInternshipStatus.active)
            .length;
        final int completedInternships = students
            .where(
              (student) => student.status == StudentInternshipStatus.completed,
            )
            .length;
        final int needingAttention = students
            .where((student) => student.status == StudentInternshipStatus.atRisk)
            .length;

        final int averageAttendance = filteredStudents.isEmpty
            ? 0
            : (filteredStudents
                        .map((student) => student.attendance)
                        .reduce((a, b) => a + b) /
                    filteredStudents.length)
                .round();
        final int lowAttendanceStudents = filteredStudents
            .where((student) => student.attendance < 75)
            .length;
        final int weeklyCheckIns = filteredStudents
            .map((student) => student.weeklyCheckIns)
            .fold<int>(0, (sum, value) => sum + value);
        final int missedLogs = filteredStudents
            .map((student) => student.missedLogs)
            .fold<int>(0, (sum, value) => sum + value);

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showSidePanel =
                _selectedStudent != null && constraints.maxWidth >= 1240;
            final double contentMaxWidth = showSidePanel ? 860 : 1180;

            return Stack(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _StudentsHero(totalStudents: totalStudents),
                                const SizedBox(height: 22),
                                LayoutBuilder(
                                  builder: (context, summaryConstraints) {
                                    final int columns = _resolveColumns(
                                      width: summaryConstraints.maxWidth,
                                      minTileWidth: 220,
                                    );
                                    final double spacing = 16;
                                    final double cardWidth =
                                        (summaryConstraints.maxWidth -
                                                ((columns - 1) * spacing)) /
                                            columns;

                                    return Wrap(
                                      spacing: spacing,
                                      runSpacing: spacing,
                                      children: <Widget>[
                                        SizedBox(
                                          width: cardWidth,
                                          child: StudentSummaryCard(
                                            title: 'Total Students',
                                            value: '$totalStudents',
                                            subtitle:
                                                'Across all departments in Firebase',
                                            icon: Icons.groups_rounded,
                                            accentColor: AppColors.coolSky,
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: StudentSummaryCard(
                                            title: 'Active Internships',
                                            value: '$activeInternships',
                                            subtitle:
                                                'Students currently marked ongoing',
                                            icon: Icons.work_history_rounded,
                                            accentColor: AppColors.aquamarine,
                                            animationDelay: const Duration(
                                              milliseconds: 80,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: StudentSummaryCard(
                                            title: 'Completed Internships',
                                            value: '$completedInternships',
                                            subtitle:
                                                'Students who finished successfully',
                                            icon: Icons.task_alt_rounded,
                                            accentColor: AppColors.jasmine,
                                            animationDelay: const Duration(
                                              milliseconds: 160,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: StudentSummaryCard(
                                            title: 'Needing Attention',
                                            value: '$needingAttention',
                                            subtitle:
                                                'Students currently flagged at risk',
                                            icon:
                                                Icons.priority_high_rounded,
                                            accentColor:
                                                AppColors.strawberryRed,
                                            animationDelay: const Duration(
                                              milliseconds: 240,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                StudentFilterBar(
                                  selectedDepartment: _selectedDepartment,
                                  selectedYear: _selectedYear,
                                  selectedStatus: _selectedStatus,
                                  searchQuery: _searchQuery,
                                  departmentOptions: departmentOptions,
                                  onDepartmentChanged: (value) {
                                    setState(() => _selectedDepartment = value);
                                  },
                                  onYearChanged: (value) {
                                    setState(() => _selectedYear = value);
                                  },
                                  onStatusChanged: (value) {
                                    setState(() => _selectedStatus = value);
                                  },
                                  onSearchChanged: (value) {
                                    setState(() => _searchQuery = value);
                                  },
                                  onReset: _resetFilters,
                                ),
                                const SizedBox(height: 22),
                                if (filteredStudents.isEmpty)
                                  const _StudentsEmptyState()
                                else
                                  LayoutBuilder(
                                    builder: (context, tableConstraints) {
                                      final bool stacked =
                                          tableConstraints.maxWidth < 1120;

                                      if (stacked) {
                                        return Column(
                                          children: <Widget>[
                                            StudentsTable(
                                              students: filteredStudents,
                                              onView: _handleView,
                                              onEdit: _handleEdit,
                                              onMessage: _handleMessage,
                                            ),
                                            const SizedBox(height: 18),
                                            AttendanceOverviewCard(
                                              averageAttendance:
                                                  averageAttendance,
                                              lowAttendanceStudents:
                                                  lowAttendanceStudents,
                                              weeklyCheckIns: weeklyCheckIns,
                                              missedLogs: missedLogs,
                                            ),
                                          ],
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 4,
                                            child: StudentsTable(
                                              students: filteredStudents,
                                              onView: _handleView,
                                              onEdit: _handleEdit,
                                              onMessage: _handleMessage,
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            flex: 2,
                                            child: AttendanceOverviewCard(
                                              averageAttendance:
                                                  averageAttendance,
                                              lowAttendanceStudents:
                                                  lowAttendanceStudents,
                                              weeklyCheckIns: weeklyCheckIns,
                                              missedLogs: missedLogs,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showSidePanel) ...<Widget>[
                      const SizedBox(width: 20),
                      _PanelEntrance(
                        child: SizedBox(
                          width: 390,
                          child: StudentDetailScreen(
                            student: _selectedStudent!,
                            onClose: () =>
                                setState(() => _selectedStudent = null),
                            onEdit: _handleEdit,
                            onMessage: _handleMessage,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_selectedStudent != null && !showSidePanel)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.overlay,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedStudent = null),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          _PanelEntrance(
                            child: SizedBox(
                              width: constraints.maxWidth.clamp(320.0, 440.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: StudentDetailScreen(
                                  student: _selectedStudent!,
                                  onClose: () =>
                                      setState(() => _selectedStudent = null),
                                  onEdit: _handleEdit,
                                  onMessage: _handleMessage,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Stream<List<StudentRecord>> _watchStudents() {
    late final StreamController<List<StudentRecord>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? usersSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? recordsSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? tasksSubscription;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs =
        <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> recordDocs =
        <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> taskDocs =
        <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    void emitCombined() {
      try {
        final List<StudentRecord> students = userDocs
            .map(StudentRecord.fromFirestore)
            .where((student) => student.isDeleted != true)
            .map(
              (student) {
                final StudentRecord withAttendance = _applyAttendanceMetrics(
                  student,
                  _resolveAttendanceMetrics(student, recordDocs),
                );
                return _applyTaskProgress(
                  withAttendance,
                  _resolveTaskProgress(withAttendance, taskDocs),
                );
              },
            )
            .toList(growable: false);
        controller.add(students);
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<StudentRecord>>(
      onListen: () {
        usersSubscription = _firestore
            .collection('user')
            .where('role', isEqualTo: 'student')
            .snapshots()
            .listen(
              (snapshot) {
                userDocs = snapshot.docs;
                emitCombined();
              },
              onError: controller.addError,
            );

        recordsSubscription = _firestore
            .collectionGroup('records')
            .snapshots()
            .listen(
              (snapshot) {
                recordDocs = snapshot.docs;
                emitCombined();
              },
              onError: controller.addError,
            );

        tasksSubscription = _firestore.collection('tasks').snapshots().listen(
          (snapshot) {
            taskDocs = snapshot.docs;
            emitCombined();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await usersSubscription?.cancel();
        await recordsSubscription?.cancel();
        await tasksSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  StudentRecord _applyAttendanceMetrics(
    StudentRecord student,
    _AttendanceMetrics? attendance,
  ) {
    if (attendance == null) {
      return student;
    }

    return student.copyWith(
      attendance: attendance.percentage,
      weeklyCheckIns: attendance.presentCount,
      missedLogs: attendance.absentCount,
    );
  }

  StudentRecord _applyTaskProgress(
    StudentRecord student,
    int? progressPercentage,
  ) {
    if (progressPercentage == null) {
      return student;
    }

    return student.copyWith(progress: progressPercentage);
  }

  _AttendanceMetrics? _resolveAttendanceMetrics(
    StudentRecord student,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> recordDocs,
  ) {
    int totalCount = 0;
    int presentCount = 0;
    int absentCount = 0;
    int completedTasks = 0;
    int totalTasks = 0;
    int progressSamples = 0;
    int progressTotal = 0;

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in recordDocs) {
      final _AttendanceRecord record = _AttendanceRecord.fromFirestore(doc);
      if (!_matchesStudent(record, student)) {
        continue;
      }

      if (record.isPresent == true) {
        totalCount++;
        presentCount++;
      } else if (record.isPresent == false) {
        totalCount++;
        absentCount++;
      }

      if (record.completedTasks != null && record.totalTasks != null) {
        completedTasks += record.completedTasks!;
        totalTasks += record.totalTasks!;
      } else if (record.progressPercentage != null) {
        progressSamples++;
        progressTotal += record.progressPercentage!;
      }
    }

    if (totalCount == 0) {
      return null;
    }

    final int progressPercentage = totalTasks > 0
        ? ((completedTasks / totalTasks) * 100).round()
        : progressSamples > 0
        ? (progressTotal / progressSamples).round()
        : student.progress;

    return _AttendanceMetrics(
      percentage: ((presentCount / totalCount) * 100).round(),
      presentCount: presentCount,
      absentCount: absentCount,
      progressPercentage: progressPercentage.clamp(0, 100),
    );
  }

  int? _resolveTaskProgress(
    StudentRecord student,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> taskDocs,
  ) {
    int totalTasks = 0;
    int completedTasks = 0;

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in taskDocs) {
      final _TaskRecord task = _TaskRecord.fromFirestore(doc);
      if (!_matchesTask(task, student)) {
        continue;
      }

      totalTasks++;
      if (task.isCompleted) {
        completedTasks++;
      }
    }

    if (totalTasks == 0) {
      return null;
    }

    return ((completedTasks / totalTasks) * 100).round().clamp(0, 100);
  }

  bool _matchesStudent(_AttendanceRecord attendance, StudentRecord student) {
    final Set<String> studentIds = <String>{
      student.id.trim().toLowerCase(),
      student.email.trim().toLowerCase(),
      student.rollNumber.trim().toLowerCase(),
    }..removeWhere((value) => value.isEmpty || value == 'n/a');

    final Set<String> attendanceIds = <String>{
      attendance.studentId,
      attendance.studentEmail,
      attendance.rollNumber,
      attendance.attendanceDocumentId,
    }..removeWhere((value) => value.isEmpty || value == 'n/a');

    return attendanceIds.any(studentIds.contains);
  }

  bool _matchesTask(_TaskRecord task, StudentRecord student) {
    final Set<String> studentIds = <String>{
      student.id.trim().toLowerCase(),
      student.email.trim().toLowerCase(),
      student.rollNumber.trim().toLowerCase(),
      student.name.trim().toLowerCase(),
    }..removeWhere((value) => value.isEmpty || value == 'n/a');

    final Set<String> taskIds = <String>{
      task.assignedToStudentId,
      task.studentEmail,
      task.rollNumber,
      task.studentName,
    }..removeWhere((value) => value.isEmpty || value == 'n/a');

    return taskIds.any(studentIds.contains);
  }

  List<StudentRecord> _filterStudents(List<StudentRecord> students) {
    final String query = _searchQuery.trim().toLowerCase();

    return students.where((student) {
      final bool departmentMatches =
          _selectedDepartment == null || student.department == _selectedDepartment;
      final bool yearMatches =
          _selectedYear == null || student.year == _selectedYear;
      final bool statusMatches =
          _selectedStatus == null || student.status == _selectedStatus;
      final bool searchMatches =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query) ||
          student.company.toLowerCase().contains(query);

      return departmentMatches &&
          yearMatches &&
          statusMatches &&
          searchMatches;
    }).toList(growable: false);
  }

  void _syncSelection(List<StudentRecord> students) {
    if (_selectedStudent == null) {
      return;
    }

    StudentRecord? refreshedSelection;
    for (final StudentRecord student in students) {
      if (student.id == _selectedStudent!.id) {
        refreshedSelection = student;
        break;
      }
    }

    if (refreshedSelection == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedStudent = null);
        }
      });
      return;
    }

    if (refreshedSelection != _selectedStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedStudent = refreshedSelection);
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDepartment = null;
      _selectedYear = null;
      _selectedStatus = null;
      _searchQuery = '';
    });
  }

  void _handleView(StudentRecord student) {
    setState(() => _selectedStudent = student);
  }

  void _handleEdit(StudentRecord student) {
    _showAttendanceEditor(student);
  }

  void _handleMessage(StudentRecord student) {
    _showDeleteConfirmation(student);
  }

  Future<void> _showDeleteConfirmation(StudentRecord student) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student?'),
          content: Text(
            'Are you sure you want to delete ${student.name}? You can undo this action for a short time.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strawberryRed,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _performSoftDelete(student);
    }
  }

  Future<void> _performSoftDelete(StudentRecord student) async {
    try {
      await _firestore
          .collection('user')
          .doc(student.id)
          .update(<String, dynamic>{
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted ${student.name}',
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(
            bottom: 24,
            left: 24,
            right: 24,
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.coolSky,
            onPressed: () => _performUndo(student),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showActionFeedback('Failed to delete student. $error');
    }
  }

  Future<void> _performUndo(StudentRecord student) async {
    try {
      await _firestore
          .collection('user')
          .doc(student.id)
          .update(<String, dynamic>{
            'isDeleted': false,
          });

      if (!mounted) {
        return;
      }

      _showActionFeedback('${student.name} restored');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showActionFeedback('Failed to undo delete. $error');
    }
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _showAttendanceEditor(StudentRecord student) async {
    final TextEditingController attendanceController =
        TextEditingController(text: student.attendance.toString());
    final TextEditingController progressController =
        TextEditingController(text: student.progress.toString());
    final TextEditingController weeklyCheckInsController =
        TextEditingController(text: student.weeklyCheckIns.toString());
    final TextEditingController missedLogsController =
        TextEditingController(text: student.missedLogs.toString());

    StudentInternshipStatus selectedStatus = student.status;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Update Attendance',
                style: AppTextStyles.sectionTitle,
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        student.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NumberField(
                        controller: attendanceController,
                        label: 'Attendance (%)',
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        controller: progressController,
                        label: 'Progress (%)',
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        controller: weeklyCheckInsController,
                        label: 'Weekly Check-ins',
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        controller: missedLogsController,
                        label: 'Missed Logs',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Internship Status',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<StudentInternshipStatus>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: StudentInternshipStatus.values
                            .map(
                              (status) => DropdownMenuItem<
                                  StudentInternshipStatus>(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => selectedStatus = value);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final int attendance = _parsePercent(
                              attendanceController.text,
                            );
                            final int progress = _parsePercent(
                              progressController.text,
                            );
                            final int weeklyCheckIns = _parseCount(
                              weeklyCheckInsController.text,
                            );
                            final int missedLogs = _parseCount(
                              missedLogsController.text,
                            );

                            await _firestore
                                .collection('user')
                                .doc(student.id)
                                .update(<String, dynamic>{
                              'attendance': attendance,
                              'attendancePercentage': attendance,
                              'progress': progress,
                              'progressPercentage': progress,
                              'weeklyCheckIns': weeklyCheckIns,
                              'checkInCount': weeklyCheckIns,
                              'missedLogs': missedLogs,
                              'missedLogCount': missedLogs,
                              'internshipStatus': selectedStatus.label,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            if (!mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();
                            _showActionFeedback(
                              'Attendance updated for ${student.name}',
                            );
                          } catch (error) {
                            setDialogState(() => isSaving = false);
                            if (!mounted) {
                              return;
                            }
                            _showActionFeedback(
                              'Failed to update attendance. $error',
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    attendanceController.dispose();
    progressController.dispose();
    weeklyCheckInsController.dispose();
    missedLogsController.dispose();
  }

  int _parsePercent(String value) {
    final int parsed = int.tryParse(value.trim()) ?? 0;
    return parsed.clamp(0, 100);
  }

  int _parseCount(String value) {
    final int parsed = int.tryParse(value.trim()) ?? 0;
    return parsed < 0 ? 0 : parsed;
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

class _AttendanceMetrics {
  const _AttendanceMetrics({
    required this.percentage,
    required this.presentCount,
    required this.absentCount,
    required this.progressPercentage,
  });

  final int percentage;
  final int presentCount;
  final int absentCount;
  final int progressPercentage;
}

class _AttendanceRecord {
  const _AttendanceRecord({
    required this.studentId,
    required this.studentEmail,
    required this.rollNumber,
    required this.attendanceDocumentId,
    required this.isPresent,
    required this.completedTasks,
    required this.totalTasks,
    required this.progressPercentage,
  });

  final String studentId;
  final String studentEmail;
  final String rollNumber;
  final String attendanceDocumentId;
  final bool? isPresent;
  final int? completedTasks;
  final int? totalTasks;
  final int? progressPercentage;

  factory _AttendanceRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic>? student =
        data['student'] is Map<String, dynamic>
            ? data['student'] as Map<String, dynamic>
            : data['student'] is Map
            ? Map<String, dynamic>.from(data['student'] as Map)
            : null;

    return _AttendanceRecord(
      studentId: _normalizedString(
        data['studentId'] ??
            data['studentUid'] ??
            data['userId'] ??
            data['uid'] ??
            student?['id'] ??
            student?['uid'] ??
            student?['studentId'],
      ),
      studentEmail: _normalizedString(
        data['studentEmail'] ?? data['email'] ?? student?['email'],
      ),
      rollNumber: _normalizedString(
        data['rollNumber'] ?? data['rollNo'] ?? student?['rollNumber'],
      ),
      attendanceDocumentId: _normalizedString(doc.reference.parent.parent?.id),
      isPresent: _readPresence(data),
      completedTasks: _readNullableInt(<dynamic>[
        data['completedTasks'],
        data['tasksCompleted'],
        data['doneTasks'],
        data['completedTaskCount'],
        data['completed'],
      ]),
      totalTasks: _readNullableInt(<dynamic>[
        data['totalTasks'],
        data['assignedTasks'],
        data['taskCount'],
        data['totalTaskCount'],
        data['tasksAssigned'],
      ]),
      progressPercentage: _readNullableInt(<dynamic>[
        data['taskCompletionRate'],
        data['completionRate'],
        data['progress'],
        data['progressPercentage'],
        data['completionPercentage'],
        data['taskProgress'],
      ]),
    );
  }

  static String _normalizedString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim().toLowerCase();
  }

  static bool? _readPresence(Map<String, dynamic> data) {
    final dynamic directBoolean =
        data['isPresent'] ?? data['present'] ?? data['attendance'];
    final bool? fromBoolean = _asBool(directBoolean);
    if (fromBoolean != null) {
      return fromBoolean;
    }

    final String status = _normalizedString(
      data['status'] ??
          data['attendanceStatus'] ??
          data['state'] ??
          data['remark'],
    );
    if (<String>{'present', 'p', 'attended', 'checkedin', 'checked-in'}
        .contains(status)) {
      return true;
    }
    if (<String>{'absent', 'a', 'missed', 'leave', 'notpresent'}
        .contains(status)) {
      return false;
    }

    if (data['checkInTime'] != null ||
        data['checkIn'] != null ||
        data['inTime'] != null) {
      return true;
    }

    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (<String>{'true', 'yes', '1', 'present', 'p'}.contains(normalized)) {
        return true;
      }
      if (<String>{'false', 'no', '0', 'absent', 'a'}.contains(normalized)) {
        return false;
      }
    }
    return null;
  }

  static int? _readNullableInt(List<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.round();
      }
      if (value is String) {
        final int? parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}

class _TaskRecord {
  const _TaskRecord({
    required this.assignedToStudentId,
    required this.studentEmail,
    required this.rollNumber,
    required this.studentName,
    required this.isCompleted,
  });

  final String assignedToStudentId;
  final String studentEmail;
  final String rollNumber;
  final String studentName;
  final bool isCompleted;

  factory _TaskRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();

    return _TaskRecord(
      assignedToStudentId: _normalizeTaskValue(
        data['assignedToStudentId'] ?? data['studentId'] ?? data['userId'],
      ),
      studentEmail: _normalizeTaskValue(
        data['studentEmail'] ?? data['email'],
      ),
      rollNumber: _normalizeTaskValue(
        data['rollNumber'] ?? data['rollNo'] ?? data['studentRollNumber'],
      ),
      studentName: _normalizeTaskValue(data['studentName'] ?? data['name']),
      isCompleted: _readCompletedState(data),
    );
  }

  static String _normalizeTaskValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim().toLowerCase();
  }

  static bool _readCompletedState(Map<String, dynamic> data) {
    final String status = _normalizeTaskValue(
      data['status'] ?? data['taskStatus'] ?? data['reviewStatus'],
    );

    if (<String>{
      'verified',
      'completed',
      'complete',
      'done',
      'approved',
      'closed',
      'submitted',
    }.contains(status)) {
      return true;
    }

    if (<String>{
      'pending',
      'assigned',
      'in progress',
      'inprogress',
      'working',
      'open',
      'rejected',
    }.contains(status)) {
      return false;
    }

    final dynamic done =
        data['isCompleted'] ?? data['completed'] ?? data['verified'];
    if (done is bool) {
      return done;
    }
    if (done is num) {
      return done != 0;
    }
    if (done is String) {
      return <String>{'true', 'yes', '1', 'verified', 'completed'}
          .contains(done.trim().toLowerCase());
    }

    return false;
  }
}

class _StudentsStateCard extends StatelessWidget {
  const _StudentsStateCard({
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

class _StudentsEmptyState extends StatelessWidget {
  const _StudentsEmptyState();

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
            'No students found',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no student records matching the current filters, or your user collection does not have student documents yet.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelEntrance extends StatelessWidget {
  const _PanelEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 28, 0),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _StudentsHero extends StatelessWidget {
  const _StudentsHero({required this.totalStudents});

  final int totalStudents;

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
            AppColors.coolSky.withOpacity(0.14),
            AppColors.jasmine.withOpacity(0.20),
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
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Students',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor student internships, attendance, mentors, and progress from live Firebase records.',
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
                  'Student base',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalStudents enrolled',
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

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.background,
      ),
    );
  }
}
