import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/mentor_filter_bar.dart';
import '../widgets/mentor_profile_panel.dart';
import '../widgets/mentor_stat_card.dart';
import '../widgets/mentors_table.dart';

class MentorsScreen extends StatefulWidget {
  const MentorsScreen({super.key});

  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  MentorType? _selectedType;
  String? _selectedDepartment;
  MentorStatus? _selectedStatus;
  String _searchQuery = '';
  MentorRecord? _selectedMentor;

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

  List<MentorRecord> get _filteredMentors {
    return _mentors
        .where((mentor) {
          final bool typeMatches =
              _selectedType == null || mentor.type == _selectedType;
          final bool departmentMatches =
              _selectedDepartment == null ||
              mentor.department == _selectedDepartment;
          final bool statusMatches =
              _selectedStatus == null || mentor.status == _selectedStatus;
          final String query = _searchQuery.trim().toLowerCase();
          final bool searchMatches =
              query.isEmpty ||
              mentor.name.toLowerCase().contains(query) ||
              mentor.email.toLowerCase().contains(query) ||
              mentor.designation.toLowerCase().contains(query) ||
              mentor.primaryGroup.toLowerCase().contains(query);

          return typeMatches &&
              departmentMatches &&
              statusMatches &&
              searchMatches;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final int totalMentors = _mentors.length;
    final int facultyMentors = _mentors
        .where((mentor) => mentor.type == MentorType.faculty)
        .length;
    final int companyMentors = _mentors
        .where((mentor) => mentor.type == MentorType.company)
        .length;
    final int highWorkloadMentors = _mentors
        .where((mentor) => mentor.assignedStudents >= 10)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidePanel =
            _selectedMentor != null && constraints.maxWidth >= 1240;
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
                            _MentorsHero(totalMentors: totalMentors),
                            const SizedBox(height: 22),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final int columns = _resolveColumns(
                                  constraints.maxWidth,
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
                                      child: MentorStatCard(
                                        title: 'Total Mentors',
                                        value: '$totalMentors',
                                        subtitle: 'Across all workflows',
                                        icon: Icons.groups_rounded,
                                        accentColor: AppColors.coolSky,
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: MentorStatCard(
                                        title: 'Faculty Mentors',
                                        value: '$facultyMentors',
                                        subtitle: 'Campus mentor network',
                                        icon: Icons.school_rounded,
                                        accentColor: AppColors.aquamarine,
                                        animationDelay: const Duration(
                                          milliseconds: 80,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: MentorStatCard(
                                        title: 'Company Mentors',
                                        value: '$companyMentors',
                                        subtitle: 'Industry collaborations',
                                        icon: Icons.business_center_rounded,
                                        accentColor: AppColors.jasmine,
                                        animationDelay: const Duration(
                                          milliseconds: 160,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: MentorStatCard(
                                        title: 'High Workload Mentors',
                                        value: '$highWorkloadMentors',
                                        subtitle: 'Monitoring assignment load',
                                        icon:
                                            Icons.local_fire_department_rounded,
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
                            MentorFilterBar(
                              selectedType: _selectedType,
                              selectedDepartment: _selectedDepartment,
                              selectedStatus: _selectedStatus,
                              searchQuery: _searchQuery,
                              departmentOptions: _departmentOptions,
                              onTypeChanged: (value) {
                                setState(() => _selectedType = value);
                              },
                              onDepartmentChanged: (value) {
                                setState(() => _selectedDepartment = value);
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
                            MentorsTable(
                              mentors: _filteredMentors,
                              onView: _handleView,
                              onEdit: _handleEdit,
                              onMessage: _handleMessage,
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
                      child: MentorProfilePanel(
                        mentor: _selectedMentor!,
                        onClose: () => setState(() => _selectedMentor = null),
                        onEdit: _handleEdit,
                        onMessage: _handleMessage,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_selectedMentor != null && !showSidePanel)
              Positioned.fill(
                child: Container(
                  color: AppColors.overlay,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMentor = null),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      _PanelEntrance(
                        child: SizedBox(
                          width: constraints.maxWidth.clamp(320.0, 440.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: MentorProfilePanel(
                              mentor: _selectedMentor!,
                              onClose: () =>
                                  setState(() => _selectedMentor = null),
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
      _selectedType = null;
      _selectedDepartment = null;
      _selectedStatus = null;
      _searchQuery = '';
    });
  }

  void _handleView(MentorRecord mentor) {
    setState(() {
      _selectedMentor = mentor;
    });
  }

  void _handleEdit(MentorRecord mentor) {
    _showActionFeedback('Editing ${mentor.name}');
  }

  void _handleMessage(MentorRecord mentor) {
    _showActionFeedback('Messaging ${mentor.name}');
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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

class _MentorsHero extends StatelessWidget {
  const _MentorsHero({required this.totalMentors});

  final int totalMentors;

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
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Mentors',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage faculty and company mentors across internship workflows',
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
                  'Active mentor base',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalMentors mentors',
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

const List<MentorRecord> _mentors = <MentorRecord>[
  MentorRecord(
    id: 'men-001',
    name: 'Prof. Nisha Patwardhan',
    email: 'nisha.patwardhan@interntracker.dev',
    type: MentorType.faculty,
    department: 'Information Technology',
    company: null,
    phoneNumber: '+91 98765 12001',
    designation: 'Associate Professor',
    assignedStudents: 9,
    activeInternships: 7,
    status: MentorStatus.active,
    notes:
        'Consistently supports weekly reviews and maintains strong documentation discipline for student progress.',
    studentPreview: <String>['Aditi Sharma', 'Rhea Thomas', 'Soham Kulkarni'],
  ),
  MentorRecord(
    id: 'men-002',
    name: 'Dr. Amol Jadhav',
    email: 'amol.jadhav@interntracker.dev',
    type: MentorType.faculty,
    department: 'Computer Engineering',
    company: null,
    phoneNumber: '+91 98765 12002',
    designation: 'Professor',
    assignedStudents: 12,
    activeInternships: 10,
    status: MentorStatus.busy,
    notes:
        'Currently carrying a high review load across backend and systems-focused student cohorts.',
    studentPreview: <String>['Rahul Verma', 'Mitali Deshpande', 'Aditya Joshi'],
  ),
  MentorRecord(
    id: 'men-003',
    name: 'Rohan Kulkarni',
    email: 'rohan.kulkarni@infosys.com',
    type: MentorType.company,
    department: null,
    company: 'Infosys Pune',
    phoneNumber: '+91 99871 33001',
    designation: 'Engineering Manager',
    assignedStudents: 6,
    activeInternships: 5,
    status: MentorStatus.active,
    notes:
        'Provides strong onboarding support and structured weekly goals for app development interns.',
    studentPreview: <String>['Aditi Sharma', 'Vivek Patil'],
  ),
  MentorRecord(
    id: 'men-004',
    name: 'Ananya Rao',
    email: 'ananya.rao@tcs.com',
    type: MentorType.company,
    department: null,
    company: 'TCS Pune',
    phoneNumber: '+91 99871 33002',
    designation: 'ML Lead',
    assignedStudents: 8,
    activeInternships: 8,
    status: MentorStatus.busy,
    notes:
        'Oversees AI/ML interns and frequently coordinates with faculty on model evaluation deliverables.',
    studentPreview: <String>['Priya Nair', 'Harshad More', 'Tejal Kale'],
  ),
  MentorRecord(
    id: 'men-005',
    name: 'Dr. Sameer Kulkarni',
    email: 'sameer.kulkarni@interntracker.dev',
    type: MentorType.faculty,
    department: 'Electronics & Telecommunication',
    company: null,
    phoneNumber: '+91 98765 12005',
    designation: 'Associate Professor',
    assignedStudents: 5,
    activeInternships: 4,
    status: MentorStatus.active,
    notes:
        'Focused on embedded and hardware-oriented student mentorship with strong academic follow-through.',
    studentPreview: <String>['Meera Joshi', 'Saket Borse'],
  ),
  MentorRecord(
    id: 'men-006',
    name: 'Deepa Iyer',
    email: 'deepa.iyer@capgemini.com',
    type: MentorType.company,
    department: null,
    company: 'Capgemini',
    phoneNumber: '+91 99871 33006',
    designation: 'QA Practice Lead',
    assignedStudents: 3,
    activeInternships: 2,
    status: MentorStatus.inactive,
    notes:
        'Temporarily unavailable for new assignments while transitioning current intern review ownership.',
    studentPreview: <String>['Rhea Thomas'],
  ),
  MentorRecord(
    id: 'men-007',
    name: 'Prof. Kedar Sawant',
    email: 'kedar.sawant@interntracker.dev',
    type: MentorType.faculty,
    department: 'Automobile Engineering',
    company: null,
    phoneNumber: '+91 98765 12007',
    designation: 'Assistant Professor',
    assignedStudents: 7,
    activeInternships: 6,
    status: MentorStatus.active,
    notes:
        'Keeps close watch on EV and automotive student reports with consistent mentor follow-ups.',
    studentPreview: <String>['Sneha Patil', 'Yash Gite'],
  ),
  MentorRecord(
    id: 'men-008',
    name: 'Komal Ahuja',
    email: 'komal.ahuja@studioweave.com',
    type: MentorType.company,
    department: null,
    company: 'Studio Weave',
    phoneNumber: '+91 99871 33008',
    designation: 'Production Director',
    assignedStudents: 4,
    activeInternships: 4,
    status: MentorStatus.active,
    notes:
        'Supports garment production interns with detailed process reviews and weekly output evaluations.',
    studentPreview: <String>['Komal Shinde', 'Nikita More'],
  ),
];
