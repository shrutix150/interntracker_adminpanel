import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<MentorRecord>> _mentorsStream = _watchMentors();

  MentorType? _selectedType;
  String? _selectedDepartment;
  MentorStatus? _selectedStatus;
  String _searchQuery = '';
  MentorRecord? _selectedMentor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MentorRecord>>(
      stream: _mentorsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _MentorsStateCard(
            message: 'Unable to load mentors right now. ${snapshot.error}',
            icon: Icons.error_outline_rounded,
          );
        }

        if (!snapshot.hasData) {
          return const _MentorsStateCard(
            message: 'Loading mentors from Firebase...',
            icon: Icons.hourglass_top_rounded,
            showLoader: true,
          );
        }

        final List<MentorRecord> mentors = snapshot.data!;
        final List<MentorRecord> filteredMentors = _filterMentors(mentors);
        final List<String> departmentOptions = mentors
            .where((mentor) => mentor.type == MentorType.faculty)
            .map((mentor) => mentor.department?.trim() ?? '')
            .where((department) => department.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        _syncSelection(mentors);

        final int totalMentors = mentors.length;
        final int facultyMentors = mentors
            .where((mentor) => mentor.type == MentorType.faculty)
            .length;
        final int companyMentors = mentors
            .where((mentor) => mentor.type == MentorType.company)
            .length;
        final int pendingMentors = mentors
            .where((mentor) => mentor.status == MentorStatus.pending)
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
                                  builder: (context, innerConstraints) {
                                    final int columns = _resolveColumns(
                                      innerConstraints.maxWidth,
                                    );
                                    final double spacing = 16;
                                    final double cardWidth =
                                        (innerConstraints.maxWidth -
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
                                            subtitle:
                                                'Live mentor accounts in Firebase',
                                            icon: Icons.groups_rounded,
                                            accentColor: AppColors.coolSky,
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: MentorStatCard(
                                            title: 'Faculty Mentors',
                                            value: '$facultyMentors',
                                            subtitle: 'Accounts with role faculty',
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
                                            subtitle: 'Accounts with role mentor',
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
                                            title: 'Pending Approval',
                                            value: '$pendingMentors',
                                            subtitle: 'Mentors awaiting approval',
                                            icon: Icons.pending_actions_rounded,
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
                                MentorFilterBar(
                                  selectedType: _selectedType,
                                  selectedDepartment: _selectedDepartment,
                                  selectedStatus: _selectedStatus,
                                  searchQuery: _searchQuery,
                                  departmentOptions: departmentOptions,
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
                                if (filteredMentors.isEmpty)
                                  const _MentorsEmptyState()
                                else
                                  MentorsTable(
                                    mentors: filteredMentors,
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
      },
    );
  }

  Stream<List<MentorRecord>> _watchMentors() {
    return _firestore
        .collection('user')
        .where('role', whereIn: <String>['mentor', 'faculty'])
        .snapshots()
        .map((snapshot) {
          final List<MentorRecord> mentors = snapshot.docs
              .map(MentorRecord.fromFirestore)
              .toList(growable: false)
            ..sort((a, b) {
              final DateTime aDate =
                  a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final DateTime bDate =
                  b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final int dateComparison = bDate.compareTo(aDate);
              if (dateComparison != 0) {
                return dateComparison;
              }
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });

          return mentors;
        });
  }

  List<MentorRecord> _filterMentors(List<MentorRecord> mentors) {
    return mentors.where((mentor) {
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
          mentor.primaryGroup.toLowerCase().contains(query) ||
          mentor.phoneNumber.toLowerCase().contains(query) ||
          mentor.employeeId.toLowerCase().contains(query);

      return typeMatches &&
          departmentMatches &&
          statusMatches &&
          searchMatches;
    }).toList(growable: false);
  }

  void _syncSelection(List<MentorRecord> mentors) {
    final MentorRecord? selectedMentor = _selectedMentor;
    if (selectedMentor == null) {
      return;
    }

    MentorRecord? refreshed;
    for (final MentorRecord mentor in mentors) {
      if (mentor.id == selectedMentor.id) {
        refreshed = mentor;
        break;
      }
    }

    if (refreshed == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _selectedMentor = null);
      });
      return;
    }

    if (!identical(refreshed, selectedMentor)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _selectedMentor = refreshed);
      });
    }
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
                  'Manage faculty and company mentors from live Firebase user records.',
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

class _MentorsStateCard extends StatelessWidget {
  const _MentorsStateCard({
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

class _MentorsEmptyState extends StatelessWidget {
  const _MentorsEmptyState();

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
            'No mentors found',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'No faculty or mentor documents in the Firebase user collection match the current filters.',
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
