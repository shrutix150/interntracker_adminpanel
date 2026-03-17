import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/report_detail_modal.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_stats_cards.dart';
import '../widgets/reports_table.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<WeeklyReportRecord> _reports = _seedReports;
  String? _selectedDepartment;
  ReportStatus? _selectedStatus;
  String? _selectedWeek;
  String _searchQuery = '';
  WeeklyReportRecord? _selectedReport;

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

  static const List<String> _weekOptions = <String>[
    'Week 1',
    'Week 2',
    'Week 3',
    'Week 4',
    'Week 5',
    'Week 6',
    'Week 7',
    'Week 8',
  ];

  List<WeeklyReportRecord> get _filteredReports {
    return _reports
        .where((report) {
          final bool departmentMatches =
              _selectedDepartment == null ||
              report.department == _selectedDepartment;
          final bool statusMatches =
              _selectedStatus == null || report.status == _selectedStatus;
          final bool weekMatches =
              _selectedWeek == null || report.week == _selectedWeek;
          final String query = _searchQuery.trim().toLowerCase();
          final bool searchMatches =
              query.isEmpty ||
              report.studentName.toLowerCase().contains(query) ||
              report.studentEmail.toLowerCase().contains(query) ||
              report.rollNumber.toLowerCase().contains(query) ||
              report.reportTitle.toLowerCase().contains(query);

          return departmentMatches &&
              statusMatches &&
              weekMatches &&
              searchMatches;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final int totalReports = _reports.length;
    final int pendingReview = _reports
        .where((report) => report.status == ReportStatus.pending)
        .length;
    final int reviewed = _reports
        .where((report) => report.status == ReportStatus.reviewed)
        .length;
    final int correctionsRequested = _reports
        .where((report) => report.status == ReportStatus.correctionsRequested)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidePanel =
            _selectedReport != null && constraints.maxWidth >= 1240;
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
                            _ReportsHero(totalReports: totalReports),
                            const SizedBox(height: 22),
                            ReportStatsCards(
                              totalReports: totalReports,
                              pendingReview: pendingReview,
                              reviewed: reviewed,
                              correctionsRequested: correctionsRequested,
                            ),
                            const SizedBox(height: 22),
                            ReportFilterBar(
                              selectedDepartment: _selectedDepartment,
                              selectedStatus: _selectedStatus,
                              selectedWeek: _selectedWeek,
                              searchQuery: _searchQuery,
                              departmentOptions: _departmentOptions,
                              weekOptions: _weekOptions,
                              onDepartmentChanged: (value) {
                                setState(() => _selectedDepartment = value);
                              },
                              onStatusChanged: (value) {
                                setState(() => _selectedStatus = value);
                              },
                              onWeekChanged: (value) {
                                setState(() => _selectedWeek = value);
                              },
                              onSearchChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              onReset: _resetFilters,
                            ),
                            const SizedBox(height: 22),
                            ReportsTable(
                              reports: _filteredReports,
                              onView: _handleView,
                              onReview: _handleReview,
                              onRequestCorrection: _handleRequestCorrection,
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
                      child: ReportDetailModal(
                        report: _selectedReport!,
                        onClose: () => setState(() => _selectedReport = null),
                        onMarkReviewed: _handleReview,
                        onRequestCorrection: _handleRequestCorrection,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_selectedReport != null && !showSidePanel)
              Positioned.fill(
                child: Container(
                  color: AppColors.overlay,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedReport = null),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      _PanelEntrance(
                        child: SizedBox(
                          width: constraints.maxWidth.clamp(320.0, 440.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ReportDetailModal(
                              report: _selectedReport!,
                              onClose: () =>
                                  setState(() => _selectedReport = null),
                              onMarkReviewed: _handleReview,
                              onRequestCorrection: _handleRequestCorrection,
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
      _selectedStatus = null;
      _selectedWeek = null;
      _searchQuery = '';
    });
  }

  void _handleView(WeeklyReportRecord report) {
    setState(() {
      _selectedReport = report;
    });
  }

  void _handleReview(WeeklyReportRecord report) {
    _updateReportStatus(report.id, ReportStatus.reviewed);
  }

  void _handleRequestCorrection(WeeklyReportRecord report) {
    _updateReportStatus(report.id, ReportStatus.correctionsRequested);
  }

  void _updateReportStatus(String reportId, ReportStatus status) {
    setState(() {
      _reports = _reports
          .map(
            (report) => report.id == reportId
                ? report.copyWith(status: status)
                : report,
          )
          .toList(growable: false);

      if (_selectedReport?.id == reportId) {
        _selectedReport = _selectedReport?.copyWith(status: status);
      }
    });
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({required this.totalReports});

  final int totalReports;

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
            AppColors.tangerineDream.withOpacity(0.14),
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
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reports',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review internship submissions, statuses, and feedback',
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
                  'This month',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalReports reports',
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

const List<WeeklyReportRecord> _seedReports = <WeeklyReportRecord>[
  WeeklyReportRecord(
    id: 'rep-001',
    studentName: 'Aditi Sharma',
    studentEmail: 'aditi.sharma@interntracker.dev',
    rollNumber: 'IT23014',
    department: 'Information Technology',
    week: 'Week 1',
    reportTitle: 'Frontend onboarding and module familiarization',
    submittedDate: '12 Mar 2026',
    status: ReportStatus.pending,
    facultyMentor: 'Prof. Nisha Patwardhan',
    companyMentor: 'Rohan Kulkarni',
    summary:
        'Covered project setup, component library walkthrough, and first sprint planning with the frontend team.',
    feedback: 'Awaiting first-pass review from the faculty mentor.',
  ),
  WeeklyReportRecord(
    id: 'rep-002',
    studentName: 'Rahul Verma',
    studentEmail: 'rahul.verma@interntracker.dev',
    rollNumber: 'CE22008',
    department: 'Computer Engineering',
    week: 'Week 4',
    reportTitle: 'API optimization and database profiling summary',
    submittedDate: '10 Mar 2026',
    status: ReportStatus.reviewed,
    facultyMentor: 'Dr. Amol Jadhav',
    companyMentor: 'Snehal Patil',
    summary:
        'Documented key bottlenecks in the reporting service, profiling outcomes, and improvements in query execution time.',
    feedback:
        'Strong technical detail and clear articulation of measurable impact.',
  ),
  WeeklyReportRecord(
    id: 'rep-003',
    studentName: 'Meera Joshi',
    studentEmail: 'meera.joshi@interntracker.dev',
    rollNumber: 'ENT23021',
    department: 'Electronics & Telecommunication',
    week: 'Week 2',
    reportTitle: 'Embedded hardware validation progress',
    submittedDate: '09 Mar 2026',
    status: ReportStatus.correctionsRequested,
    facultyMentor: 'Dr. Sameer Kulkarni',
    companyMentor: 'Priyanka Menon',
    summary:
        'Outlined test cases executed on the embedded board, sensor calibration outcomes, and remaining validation blockers.',
    feedback:
        'Please add clearer evidence of test readings and include screenshots from the board logs.',
  ),
  WeeklyReportRecord(
    id: 'rep-004',
    studentName: 'Priya Nair',
    studentEmail: 'priya.nair@interntracker.dev',
    rollNumber: 'AIML22011',
    department: 'Artificial Intelligence & Machine Learning',
    week: 'Week 6',
    reportTitle: 'Model evaluation metrics and retraining notes',
    submittedDate: '08 Mar 2026',
    status: ReportStatus.approved,
    facultyMentor: 'Prof. Rahul Apte',
    companyMentor: 'Ananya Rao',
    summary:
        'Summarized retraining experiments, model drift observations, and comparison metrics across validation runs.',
    feedback:
        'Approved. Excellent clarity and strong alignment between results and recommendations.',
  ),
  WeeklyReportRecord(
    id: 'rep-005',
    studentName: 'Sneha Patil',
    studentEmail: 'sneha.patil@interntracker.dev',
    rollNumber: 'AUTO23005',
    department: 'Automobile Engineering',
    week: 'Week 3',
    reportTitle: 'EV subsystem orientation and task planning',
    submittedDate: '13 Mar 2026',
    status: ReportStatus.pending,
    facultyMentor: 'Prof. Kedar Sawant',
    companyMentor: 'Amit Dandekar',
    summary:
        'Captured the EV architecture orientation sessions, assigned subsystem tasks, and planned follow-up diagnostics work.',
    feedback: 'Submission logged. Review pending.',
  ),
  WeeklyReportRecord(
    id: 'rep-006',
    studentName: 'Aniket Deshpande',
    studentEmail: 'aniket.deshpande@interntracker.dev',
    rollNumber: 'CIV23009',
    department: 'Civil Engineering',
    week: 'Week 5',
    reportTitle: 'Site planning coordination and documentation',
    submittedDate: '11 Mar 2026',
    status: ReportStatus.reviewed,
    facultyMentor: 'Prof. Asha More',
    companyMentor: 'Shubham Kale',
    summary:
        'Provided an overview of layout revisions, site coordination steps, and documentation support handled this week.',
    feedback:
        'Reviewed. Add one short note next week on risk tracking and mitigation follow-up.',
  ),
  WeeklyReportRecord(
    id: 'rep-007',
    studentName: 'Rhea Thomas',
    studentEmail: 'rhea.thomas@interntracker.dev',
    rollNumber: 'IT22019',
    department: 'Information Technology',
    week: 'Week 7',
    reportTitle: 'QA automation backlog execution summary',
    submittedDate: '14 Mar 2026',
    status: ReportStatus.correctionsRequested,
    facultyMentor: 'Prof. Smita Dhavale',
    companyMentor: 'Deepa Iyer',
    summary:
        'Included automation scenarios completed, flaky test review, and pending backlog coverage for the regression suite.',
    feedback:
        'Please expand the execution metrics and clarify the cause of skipped scenarios.',
  ),
  WeeklyReportRecord(
    id: 'rep-008',
    studentName: 'Komal Shinde',
    studentEmail: 'komal.shinde@interntracker.dev',
    rollNumber: 'DDGM22004',
    department: 'Dress Designing & Garment Manufacturing',
    week: 'Week 8',
    reportTitle: 'Final garment production review and outcomes',
    submittedDate: '07 Mar 2026',
    status: ReportStatus.approved,
    facultyMentor: 'Prof. Neha Bhosale',
    companyMentor: 'Komal Ahuja',
    summary:
        'Presented final production outcomes, quality review observations, and recommendations for process refinement.',
    feedback:
        'Approved. Final report is well-structured and professionally documented.',
  ),
];
