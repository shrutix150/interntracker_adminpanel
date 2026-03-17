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
  String? _selectedDepartment;
  StudentYear? _selectedYear;
  StudentInternshipStatus? _selectedStatus;
  String _searchQuery = '';
  StudentRecord? _selectedStudent;

  static const List<String> _departmentOptions = <String>[
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

  List<StudentRecord> get _filteredStudents {
    return _students
        .where((student) {
          final bool departmentMatches =
              _selectedDepartment == null ||
              student.department == _selectedDepartment;
          final bool yearMatches =
              _selectedYear == null || student.year == _selectedYear;
          final bool statusMatches =
              _selectedStatus == null || student.status == _selectedStatus;
          final String query = _searchQuery.trim().toLowerCase();
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
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<StudentRecord> filteredStudents = _filteredStudents;
    final int totalStudents = _students.length;
    final int activeInternships = _students
        .where((student) => student.status == StudentInternshipStatus.active)
        .length;
    final int completedInternships = _students
        .where((student) => student.status == StudentInternshipStatus.completed)
        .length;
    final int needingAttention = _students
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
        .where((student) => student.progress >= 60)
        .length;
    final int missedLogs = filteredStudents
        .where((student) => student.progress < 50)
        .length;

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
                              builder: (context, constraints) {
                                final int columns = _resolveColumns(
                                  width: constraints.maxWidth,
                                  minTileWidth: 220,
                                );
                                final double spacing = 16;
                                final double cardWidth =
                                    (constraints.maxWidth -
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
                                        subtitle: 'Across all departments',
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
                                            'Currently ongoing placements',
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
                                            'Finished and logged successfully',
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
                                            'Attendance or progress flagged',
                                        icon: Icons.priority_high_rounded,
                                        accentColor: AppColors.strawberryRed,
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
                              departmentOptions: _departmentOptions,
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final bool stacked =
                                    constraints.maxWidth < 1120;

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
                                        averageAttendance: averageAttendance,
                                        lowAttendanceStudents:
                                            lowAttendanceStudents,
                                        weeklyCheckIns: weeklyCheckIns,
                                        missedLogs: missedLogs,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        averageAttendance: averageAttendance,
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
                        onClose: () => setState(() => _selectedStudent = null),
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
                          onTap: () => setState(() => _selectedStudent = null),
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
    setState(() {
      _selectedStudent = student;
    });
  }

  void _handleEdit(StudentRecord student) {
    _showActionFeedback('Editing ${student.name}');
  }

  void _handleMessage(StudentRecord student) {
    _showActionFeedback('Messaging ${student.name}');
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
            AppColors.jasmine.withOpacity(0.2),
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
                  'Monitor student internships, attendance, mentors, and progress',
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

const List<StudentRecord> _students = <StudentRecord>[
  StudentRecord(
    id: 'std-001',
    name: 'Aditi Sharma',
    email: 'aditi.sharma@interntracker.dev',
    rollNumber: 'IT23014',
    department: 'Information Technology',
    year: StudentYear.thirdYear,
    company: 'Infosys Pune',
    internshipRole: 'Flutter Developer Intern',
    duration: '16 Weeks',
    startDate: '10 Jan 2026',
    endDate: '02 May 2026',
    facultyMentor: 'Prof. Nisha Patwardhan',
    companyMentor: 'Rohan Kulkarni',
    status: StudentInternshipStatus.active,
    attendance: 92,
    progress: 76,
    weeklyCheckIns: 11,
    missedLogs: 1,
    notes: 'Strong delivery pace with consistently timely weekly updates.',
  ),
  StudentRecord(
    id: 'std-002',
    name: 'Rahul Verma',
    email: 'rahul.verma@interntracker.dev',
    rollNumber: 'CE22008',
    department: 'Computer Engineering',
    year: StudentYear.fourthYear,
    company: 'Persistent Systems',
    internshipRole: 'Backend Engineering Intern',
    duration: '20 Weeks',
    startDate: '01 Dec 2025',
    endDate: '20 Apr 2026',
    facultyMentor: 'Dr. Amol Jadhav',
    companyMentor: 'Snehal Patil',
    status: StudentInternshipStatus.completed,
    attendance: 96,
    progress: 100,
    weeklyCheckIns: 14,
    missedLogs: 0,
    notes: 'Completed internship successfully with excellent mentor feedback.',
  ),
  StudentRecord(
    id: 'std-003',
    name: 'Meera Joshi',
    email: 'meera.joshi@interntracker.dev',
    rollNumber: 'ENT23021',
    department: 'Electronics & Telecommunication',
    year: StudentYear.thirdYear,
    company: 'TCS Research',
    internshipRole: 'Embedded Systems Intern',
    duration: '12 Weeks',
    startDate: '18 Jan 2026',
    endDate: '12 Apr 2026',
    facultyMentor: 'Dr. Sameer Kulkarni',
    companyMentor: 'Priyanka Menon',
    status: StudentInternshipStatus.atRisk,
    attendance: 68,
    progress: 44,
    weeklyCheckIns: 5,
    missedLogs: 4,
    notes: 'Needs follow-up on attendance and incomplete weekly check-ins.',
  ),
  StudentRecord(
    id: 'std-004',
    name: 'Karan Malhotra',
    email: 'karan.malhotra@interntracker.dev',
    rollNumber: 'ME22017',
    department: 'Mechanical Engineering',
    year: StudentYear.fourthYear,
    company: 'Bharat Forge',
    internshipRole: 'Production Planning Intern',
    duration: '18 Weeks',
    startDate: '05 Jan 2026',
    endDate: '11 May 2026',
    facultyMentor: 'Prof. Shruti Desai',
    companyMentor: 'Vikram Khedekar',
    status: StudentInternshipStatus.active,
    attendance: 88,
    progress: 72,
    weeklyCheckIns: 10,
    missedLogs: 1,
    notes: 'Good project momentum with stable attendance across the cycle.',
  ),
  StudentRecord(
    id: 'std-005',
    name: 'Sneha Patil',
    email: 'sneha.patil@interntracker.dev',
    rollNumber: 'AUTO23005',
    department: 'Automobile Engineering',
    year: StudentYear.thirdYear,
    company: 'Mahindra Electric',
    internshipRole: 'EV Systems Trainee',
    duration: '14 Weeks',
    startDate: '22 Jan 2026',
    endDate: '30 Apr 2026',
    facultyMentor: 'Prof. Kedar Sawant',
    companyMentor: 'Amit Dandekar',
    status: StudentInternshipStatus.pending,
    attendance: 81,
    progress: 38,
    weeklyCheckIns: 4,
    missedLogs: 2,
    notes: 'Offer confirmed; onboarding tasks still pending company access.',
  ),
  StudentRecord(
    id: 'std-006',
    name: 'Priya Nair',
    email: 'priya.nair@interntracker.dev',
    rollNumber: 'AIML22011',
    department: 'Artificial Intelligence & Machine Learning',
    year: StudentYear.fourthYear,
    company: 'TCS Pune',
    internshipRole: 'ML Engineering Intern',
    duration: '24 Weeks',
    startDate: '15 Dec 2025',
    endDate: '01 Jun 2026',
    facultyMentor: 'Prof. Rahul Apte',
    companyMentor: 'Ananya Rao',
    status: StudentInternshipStatus.active,
    attendance: 90,
    progress: 83,
    weeklyCheckIns: 12,
    missedLogs: 1,
    notes:
        'Performing strongly on model evaluation and reporting deliverables.',
  ),
  StudentRecord(
    id: 'std-007',
    name: 'Vikram Singh',
    email: 'vikram.singh@interntracker.dev',
    rollNumber: 'EE23012',
    department: 'Electrical Engineering',
    year: StudentYear.thirdYear,
    company: 'Siemens',
    internshipRole: 'Electrical Design Intern',
    duration: '15 Weeks',
    startDate: '27 Jan 2026',
    endDate: '12 May 2026',
    facultyMentor: 'Dr. Ritu Kulkarni',
    companyMentor: 'Neeraj Sharma',
    status: StudentInternshipStatus.pending,
    attendance: 79,
    progress: 41,
    weeklyCheckIns: 6,
    missedLogs: 2,
    notes: 'Pending final project scope confirmation from the company mentor.',
  ),
  StudentRecord(
    id: 'std-008',
    name: 'Komal Shinde',
    email: 'komal.shinde@interntracker.dev',
    rollNumber: 'DDGM22004',
    department: 'Dress Designing & Garment Manufacturing',
    year: StudentYear.fourthYear,
    company: 'Studio Weave',
    internshipRole: 'Garment Production Intern',
    duration: '16 Weeks',
    startDate: '08 Dec 2025',
    endDate: '28 Mar 2026',
    facultyMentor: 'Prof. Neha Bhosale',
    companyMentor: 'Komal Ahuja',
    status: StudentInternshipStatus.completed,
    attendance: 94,
    progress: 100,
    weeklyCheckIns: 13,
    missedLogs: 0,
    notes:
        'Completed with outstanding design presentation and production logs.',
  ),
  StudentRecord(
    id: 'std-009',
    name: 'Aniket Deshpande',
    email: 'aniket.deshpande@interntracker.dev',
    rollNumber: 'CIV23009',
    department: 'Civil Engineering',
    year: StudentYear.thirdYear,
    company: 'L&T Construction',
    internshipRole: 'Site Planning Intern',
    duration: '18 Weeks',
    startDate: '12 Jan 2026',
    endDate: '18 May 2026',
    facultyMentor: 'Prof. Asha More',
    companyMentor: 'Shubham Kale',
    status: StudentInternshipStatus.active,
    attendance: 85,
    progress: 67,
    weeklyCheckIns: 9,
    missedLogs: 1,
    notes: 'Steady progress with strong coordination on site reporting tasks.',
  ),
  StudentRecord(
    id: 'std-010',
    name: 'Rhea Thomas',
    email: 'rhea.thomas@interntracker.dev',
    rollNumber: 'IT22019',
    department: 'Information Technology',
    year: StudentYear.fourthYear,
    company: 'Capgemini',
    internshipRole: 'QA Automation Intern',
    duration: '17 Weeks',
    startDate: '19 Jan 2026',
    endDate: '18 May 2026',
    facultyMentor: 'Prof. Smita Dhavale',
    companyMentor: 'Deepa Iyer',
    status: StudentInternshipStatus.atRisk,
    attendance: 71,
    progress: 52,
    weeklyCheckIns: 6,
    missedLogs: 3,
    notes:
        'Requires mentor intervention due to low attendance and delayed logs.',
  ),
];
