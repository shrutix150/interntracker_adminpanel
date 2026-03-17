import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/approval_detail_panel.dart';
import '../widgets/approval_filter_bar.dart';
import '../widgets/approvals_table.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late List<ApprovalRequest> _requests = _seedRequests;
  ApprovalRole? _selectedRole;
  String? _selectedDepartment;
  ApprovalStatus? _selectedStatus;
  String _searchQuery = '';
  ApprovalRequest? _selectedRequest;

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

  List<ApprovalRequest> get _filteredRequests {
    return _requests
        .where((request) {
          final bool roleMatches =
              _selectedRole == null || request.role == _selectedRole;
          final bool departmentMatches =
              _selectedDepartment == null ||
              request.department == _selectedDepartment;
          final bool statusMatches =
              _selectedStatus == null || request.status == _selectedStatus;
          final String query = _searchQuery.trim().toLowerCase();
          final bool searchMatches =
              query.isEmpty ||
              request.name.toLowerCase().contains(query) ||
              request.email.toLowerCase().contains(query) ||
              request.requestType.toLowerCase().contains(query);

          return roleMatches &&
              departmentMatches &&
              statusMatches &&
              searchMatches;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidePanel =
            _selectedRequest != null && constraints.maxWidth >= 1180;
        final double contentMaxWidth = showSidePanel ? 920 : 1180;

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
                            _PageHeader(
                              pendingCount: _requests
                                  .where(
                                    (request) =>
                                        request.status ==
                                        ApprovalStatus.pending,
                                  )
                                  .length,
                            ),
                            const SizedBox(height: 18),
                            ApprovalFilterBar(
                              selectedRole: _selectedRole,
                              selectedDepartment: _selectedDepartment,
                              selectedStatus: _selectedStatus,
                              searchQuery: _searchQuery,
                              departmentOptions: _departmentOptions,
                              onRoleChanged: (role) {
                                setState(() => _selectedRole = role);
                              },
                              onDepartmentChanged: (department) {
                                setState(
                                  () => _selectedDepartment = department,
                                );
                              },
                              onStatusChanged: (status) {
                                setState(() => _selectedStatus = status);
                              },
                              onSearchChanged: (query) {
                                setState(() => _searchQuery = query);
                              },
                              onReset: _resetFilters,
                            ),
                            const SizedBox(height: 18),
                            ApprovalsTable(
                              requests: _filteredRequests,
                              onView: _handleView,
                              onApprove: _handleApprove,
                              onReject: _handleReject,
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
                      width: 380,
                      child: ApprovalDetailPanel(
                        request: _selectedRequest!,
                        onClose: () => setState(() => _selectedRequest = null),
                        onApprove: _handleApprove,
                        onReject: _handleReject,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_selectedRequest != null && !showSidePanel)
              Positioned.fill(
                child: Container(
                  color: AppColors.overlay,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRequest = null),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      _PanelEntrance(
                        child: SizedBox(
                          width: constraints.maxWidth.clamp(320.0, 440.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ApprovalDetailPanel(
                              request: _selectedRequest!,
                              onClose: () =>
                                  setState(() => _selectedRequest = null),
                              onApprove: _handleApprove,
                              onReject: _handleReject,
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

  void _handleView(ApprovalRequest request) {
    setState(() {
      _selectedRequest = request;
    });
  }

  void _handleApprove(ApprovalRequest request) {
    _updateRequestStatus(request.id, ApprovalStatus.approved);
  }

  void _handleReject(ApprovalRequest request) {
    _updateRequestStatus(request.id, ApprovalStatus.rejected);
  }

  void _updateRequestStatus(String requestId, ApprovalStatus status) {
    setState(() {
      _requests = _requests
          .map(
            (request) => request.id == requestId
                ? request.copyWith(status: status)
                : request,
          )
          .toList(growable: false);

      if (_selectedRequest?.id == requestId) {
        _selectedRequest = _selectedRequest?.copyWith(status: status);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedRole = null;
      _selectedDepartment = null;
      _selectedStatus = null;
      _searchQuery = '';
    });
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.pendingCount});

  final int pendingCount;

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
            AppColors.jasmine.withOpacity(0.24),
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
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Approvals',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review and manage pending requests',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                  'Pending queue',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount requests',
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

const List<ApprovalRequest> _seedRequests = <ApprovalRequest>[
  ApprovalRequest(
    id: 'apr-001',
    name: 'Aditi Sharma',
    email: 'aditi.sharma@interntracker.dev',
    role: ApprovalRole.student,
    department: 'Information Technology',
    requestType: 'Student registration approval',
    requestDate: '12 Mar 2026',
    status: ApprovalStatus.pending,
    notes:
        'Submitted complete registration documents and requested access to the internship reporting workspace.',
    profileSummary:
        'Third-year student with previous internship experience in frontend development and strong academic standing.',
    assignedFaculty: 'Prof. Nisha Patwardhan',
    assignedCompany: 'Infosys Pune',
  ),
  ApprovalRequest(
    id: 'apr-002',
    name: 'Rahul Verma',
    email: 'rahul.verma@interntracker.dev',
    role: ApprovalRole.facultyMentor,
    department: 'Computer Engineering',
    requestType: 'Mentor account request',
    requestDate: '11 Mar 2026',
    status: ApprovalStatus.approved,
    notes:
        'Department head recommended approval based on current mentor capacity requirements.',
    profileSummary:
        'Faculty mentor focused on placement readiness and internship evaluation for final-year students.',
    assignedCompany: 'Academic Internship Cell',
  ),
  ApprovalRequest(
    id: 'apr-003',
    name: 'Priya Nair',
    email: 'priya.nair@tcsmentor.com',
    role: ApprovalRole.companyMentor,
    department: 'Artificial Intelligence & Machine Learning',
    requestType: 'Company mentor verification',
    requestDate: '10 Mar 2026',
    status: ApprovalStatus.pending,
    notes:
        'Verification pending final company HR confirmation and updated mentor designation letter.',
    profileSummary:
        'Senior software engineer representing TCS Pune, responsible for intern onboarding and progress reviews.',
    assignedFaculty: 'Prof. Rahul Apte',
    assignedCompany: 'TCS Pune',
  ),
  ApprovalRequest(
    id: 'apr-004',
    name: 'Meera Joshi',
    email: 'meera.joshi@interntracker.dev',
    role: ApprovalRole.student,
    department: 'Electronics & Telecommunication',
    requestType: 'Internship approval request',
    requestDate: '09 Mar 2026',
    status: ApprovalStatus.rejected,
    notes:
        'Internship documentation was incomplete and the offer letter required a corrected start date.',
    profileSummary:
        'Student applicant seeking approval for an embedded systems internship with an external research lab.',
    assignedFaculty: 'Dr. Sameer Kulkarni',
    assignedCompany: 'Embedded Research Lab',
  ),
  ApprovalRequest(
    id: 'apr-005',
    name: 'Karan Malhotra',
    email: 'karan.malhotra@acmeindustries.com',
    role: ApprovalRole.companyMentor,
    department: 'Mechanical Engineering',
    requestType: 'Company mentor verification',
    requestDate: '08 Mar 2026',
    status: ApprovalStatus.pending,
    notes:
        'Awaiting review of company affiliation proof and mentor assignment scope before approval.',
    profileSummary:
        'Industry mentor for mechanical engineering interns across manufacturing operations and maintenance projects.',
    assignedFaculty: 'Prof. Shruti Desai',
    assignedCompany: 'Acme Industries',
  ),
  ApprovalRequest(
    id: 'apr-006',
    name: 'Dr. Ritu Kulkarni',
    email: 'ritu.kulkarni@interntracker.dev',
    role: ApprovalRole.hod,
    department: 'Electrical Engineering',
    requestType: 'Department approval authority request',
    requestDate: '07 Mar 2026',
    status: ApprovalStatus.pending,
    notes:
        'Requested elevated approval privileges for departmental internship review workflows.',
    profileSummary:
        'Head of Department overseeing placement coordination, internship approvals, and faculty mentor assignments.',
    assignedCompany: 'Electrical Department Office',
  ),
  ApprovalRequest(
    id: 'apr-007',
    name: 'Dr. Anil Deshmukh',
    email: 'principal@interntracker.dev',
    role: ApprovalRole.principal,
    department: 'Civil Engineering',
    requestType: 'Institutional approval access',
    requestDate: '06 Mar 2026',
    status: ApprovalStatus.approved,
    notes:
        'Institution-wide approval access requested for executive oversight on internship governance.',
    profileSummary:
        'Principal supervising academic operations, institutional compliance, and final approval escalations.',
    assignedCompany: 'Institution Governance Board',
  ),
  ApprovalRequest(
    id: 'apr-008',
    name: 'Sneha Patil',
    email: 'sneha.patil@interntracker.dev',
    role: ApprovalRole.student,
    department: 'Automobile Engineering',
    requestType: 'Student registration approval',
    requestDate: '05 Mar 2026',
    status: ApprovalStatus.pending,
    notes:
        'Applied for platform onboarding and requested access to mentor-matching and reporting modules.',
    profileSummary:
        'Student preparing for automotive systems internship applications with a focus on EV component design.',
    assignedFaculty: 'Prof. Kedar Sawant',
    assignedCompany: 'Mahindra Electric',
  ),
  ApprovalRequest(
    id: 'apr-009',
    name: 'Komal Shinde',
    email: 'komal.shinde@interntracker.dev',
    role: ApprovalRole.student,
    department: 'Dress Designing & Garment Manufacturing',
    requestType: 'Internship approval request',
    requestDate: '04 Mar 2026',
    status: ApprovalStatus.rejected,
    notes:
        'Request returned for a corrected company acceptance letter and revised reporting timeline.',
    profileSummary:
        'Student applicant pursuing a garment production and merchandising internship with a regional design studio.',
    assignedFaculty: 'Prof. Neha Bhosale',
    assignedCompany: 'Studio Weave',
  ),
];
