import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/companies_table.dart';
import '../widgets/company_detail_panel.dart';
import '../widgets/company_filter_bar.dart';
import '../widgets/company_stat_card.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  late List<CompanyRecord> _companies = _seedCompanies;
  CompanyStatus? _selectedStatus;
  String? _selectedIndustry;
  String? _selectedLocation;
  String _searchQuery = '';
  CompanyRecord? _selectedCompany;

  static const List<String> _industryOptions = <String>[
    'IT Services',
    'Software Development',
    'Electronics',
    'Manufacturing',
    'Automobile',
    'Civil / Construction',
    'Fashion / Design',
    'Training / Education',
  ];

  static const List<String> _locationOptions = <String>[
    'Nagpur',
    'Pune',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Remote',
  ];

  List<CompanyRecord> get _filteredCompanies {
    return _companies
        .where((company) {
          final bool statusMatches =
              _selectedStatus == null || company.status == _selectedStatus;
          final bool industryMatches =
              _selectedIndustry == null ||
              company.industry == _selectedIndustry;
          final bool locationMatches =
              _selectedLocation == null ||
              company.location == _selectedLocation;
          final String query = _searchQuery.trim().toLowerCase();
          final bool searchMatches =
              query.isEmpty ||
              company.name.toLowerCase().contains(query) ||
              company.contactEmail.toLowerCase().contains(query) ||
              company.website.toLowerCase().contains(query) ||
              company.companyMentor.toLowerCase().contains(query);

          return statusMatches &&
              industryMatches &&
              locationMatches &&
              searchMatches;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final int totalCompanies = _companies.length;
    final int activePartners = _companies
        .where(
          (company) =>
              company.status == CompanyStatus.active ||
              company.status == CompanyStatus.verified,
        )
        .length;
    final int studentsAssigned = _companies.fold<int>(
      0,
      (total, company) => total + company.assignedStudents,
    );
    final int pendingVerifications = _companies
        .where((company) => company.status == CompanyStatus.pending)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidePanel =
            _selectedCompany != null && constraints.maxWidth >= 1240;
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
                            _CompaniesHero(totalCompanies: activePartners),
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
                                      child: CompanyStatCard(
                                        title: 'Total Companies',
                                        value: '$totalCompanies',
                                        subtitle: 'Across all partnerships',
                                        icon: Icons.business_rounded,
                                        accentColor: AppColors.coolSky,
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: CompanyStatCard(
                                        title: 'Active Partners',
                                        value: '$activePartners',
                                        subtitle: 'Live internship partners',
                                        icon: Icons.handshake_rounded,
                                        accentColor: AppColors.aquamarine,
                                        animationDelay: const Duration(
                                          milliseconds: 80,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: CompanyStatCard(
                                        title: 'Students Assigned',
                                        value: '$studentsAssigned',
                                        subtitle:
                                            'Students placed across firms',
                                        icon: Icons.groups_rounded,
                                        accentColor: AppColors.jasmine,
                                        animationDelay: const Duration(
                                          milliseconds: 160,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: CompanyStatCard(
                                        title: 'Pending Verifications',
                                        value: '$pendingVerifications',
                                        subtitle: 'Needs admin follow-up',
                                        icon: Icons.pending_actions_rounded,
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
                            CompanyFilterBar(
                              selectedStatus: _selectedStatus,
                              selectedIndustry: _selectedIndustry,
                              selectedLocation: _selectedLocation,
                              searchQuery: _searchQuery,
                              industryOptions: _industryOptions,
                              locationOptions: _locationOptions,
                              onStatusChanged: (value) {
                                setState(() => _selectedStatus = value);
                              },
                              onIndustryChanged: (value) {
                                setState(() => _selectedIndustry = value);
                              },
                              onLocationChanged: (value) {
                                setState(() => _selectedLocation = value);
                              },
                              onSearchChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              onReset: _resetFilters,
                            ),
                            const SizedBox(height: 22),
                            CompaniesTable(
                              companies: _filteredCompanies,
                              onView: _handleView,
                              onEdit: _handleEdit,
                              onVerify: _handleVerify,
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
                      child: CompanyDetailPanel(
                        company: _selectedCompany!,
                        onClose: () => setState(() => _selectedCompany = null),
                        onEdit: _handleEdit,
                        onVerify: _handleVerify,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_selectedCompany != null && !showSidePanel)
              Positioned.fill(
                child: Container(
                  color: AppColors.overlay,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCompany = null),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      _PanelEntrance(
                        child: SizedBox(
                          width: constraints.maxWidth.clamp(320.0, 440.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CompanyDetailPanel(
                              company: _selectedCompany!,
                              onClose: () =>
                                  setState(() => _selectedCompany = null),
                              onEdit: _handleEdit,
                              onVerify: _handleVerify,
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
      _selectedStatus = null;
      _selectedIndustry = null;
      _selectedLocation = null;
      _searchQuery = '';
    });
  }

  void _handleView(CompanyRecord company) {
    setState(() {
      _selectedCompany = company;
    });
  }

  void _handleEdit(CompanyRecord company) {
    _showActionFeedback('Editing ${company.name}');
  }

  void _handleVerify(CompanyRecord company) {
    setState(() {
      _companies = _companies
          .map(
            (item) => item.id == company.id
                ? item.copyWith(status: CompanyStatus.verified)
                : item,
          )
          .toList(growable: false);
      if (_selectedCompany?.id == company.id) {
        _selectedCompany = _selectedCompany?.copyWith(
          status: CompanyStatus.verified,
        );
      }
    });
    _showActionFeedback('Verified ${company.name}');
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

class _CompaniesHero extends StatelessWidget {
  const _CompaniesHero({required this.totalCompanies});

  final int totalCompanies;

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
            AppColors.jasmine.withOpacity(0.12),
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
                  'Companies',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage internship partners, mentors, and student company assignments',
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
                  'Active companies',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCompanies partners',
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

const List<CompanyRecord> _seedCompanies = <CompanyRecord>[
  CompanyRecord(
    id: 'cmp-001',
    name: 'Infosys Pune',
    website: 'www.infosys.com',
    contactEmail: 'campus.pune@infosys.com',
    industry: 'IT Services',
    location: 'Pune',
    companyMentor: 'Rohan Kulkarni',
    assignedStudents: 12,
    activeInternships: 10,
    status: CompanyStatus.active,
    notes:
        'Long-standing internship partner with steady engineering mentorship and strong conversion outcomes.',
    studentPreview: <String>['Aditi Sharma', 'Vivek Patil', 'Rhea Thomas'],
  ),
  CompanyRecord(
    id: 'cmp-002',
    name: 'Persistent Systems',
    website: 'www.persistent.com',
    contactEmail: 'campus@persistent.com',
    industry: 'Software Development',
    location: 'Pune',
    companyMentor: 'Snehal Patil',
    assignedStudents: 9,
    activeInternships: 8,
    status: CompanyStatus.verified,
    notes:
        'Consistently provides backend and systems roles with strong weekly review discipline.',
    studentPreview: <String>['Rahul Verma', 'Aditya Joshi'],
  ),
  CompanyRecord(
    id: 'cmp-003',
    name: 'TCS Research',
    website: 'www.tcs.com',
    contactEmail: 'research.internships@tcs.com',
    industry: 'IT Services',
    location: 'Mumbai',
    companyMentor: 'Priyanka Menon',
    assignedStudents: 7,
    activeInternships: 6,
    status: CompanyStatus.active,
    notes:
        'Supports AI, research, and embedded internships with structured mentor engagement.',
    studentPreview: <String>['Meera Joshi', 'Priya Nair'],
  ),
  CompanyRecord(
    id: 'cmp-004',
    name: 'Bharat Forge',
    website: 'www.bharatforge.com',
    contactEmail: 'internships@bharatforge.com',
    industry: 'Manufacturing',
    location: 'Pune',
    companyMentor: 'Vikram Khedekar',
    assignedStudents: 5,
    activeInternships: 4,
    status: CompanyStatus.verified,
    notes:
        'Strong production-focused internship partner with stable student supervision and reporting.',
    studentPreview: <String>['Karan Malhotra'],
  ),
  CompanyRecord(
    id: 'cmp-005',
    name: 'Mahindra Electric',
    website: 'auto.mahindra.com',
    contactEmail: 'ev.internships@mahindra.com',
    industry: 'Automobile',
    location: 'Bangalore',
    companyMentor: 'Amit Dandekar',
    assignedStudents: 6,
    activeInternships: 5,
    status: CompanyStatus.pending,
    notes:
        'Partner onboarding is in progress while mentor access and student onboarding flows are being finalized.',
    studentPreview: <String>['Sneha Patil', 'Yash Gite'],
  ),
  CompanyRecord(
    id: 'cmp-006',
    name: 'Siemens',
    website: 'www.siemens.com',
    contactEmail: 'earlycareers@siemens.com',
    industry: 'Electronics',
    location: 'Mumbai',
    companyMentor: 'Neeraj Sharma',
    assignedStudents: 4,
    activeInternships: 4,
    status: CompanyStatus.active,
    notes:
        'Good match for electrical and automation tracks with detailed company-side project scoping.',
    studentPreview: <String>['Vikram Singh'],
  ),
  CompanyRecord(
    id: 'cmp-007',
    name: 'L&T Construction',
    website: 'www.larsentoubro.com',
    contactEmail: 'careers@lntconstruction.com',
    industry: 'Civil / Construction',
    location: 'Hyderabad',
    companyMentor: 'Shubham Kale',
    assignedStudents: 5,
    activeInternships: 4,
    status: CompanyStatus.active,
    notes:
        'Reliable civil internship partner with strong documentation and structured field mentorship.',
    studentPreview: <String>['Aniket Deshpande'],
  ),
  CompanyRecord(
    id: 'cmp-008',
    name: 'Studio Weave',
    website: 'www.studioweave.design',
    contactEmail: 'partners@studioweave.design',
    industry: 'Fashion / Design',
    location: 'Remote',
    companyMentor: 'Komal Ahuja',
    assignedStudents: 3,
    activeInternships: 2,
    status: CompanyStatus.inactive,
    notes:
        'Past collaboration is positive, but currently paused for the next internship intake cycle.',
    studentPreview: <String>['Komal Shinde'],
  ),
];
