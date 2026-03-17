import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'mentors_table.dart';

class MentorProfilePanel extends StatelessWidget {
  const MentorProfilePanel({
    super.key,
    required this.mentor,
    required this.onClose,
    required this.onEdit,
    required this.onMessage,
  });

  final MentorRecord mentor;
  final VoidCallback onClose;
  final ValueChanged<MentorRecord> onEdit;
  final ValueChanged<MentorRecord> onMessage;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 760;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(compact ? 26 : 30),
          bottomLeft: Radius.circular(compact ? 26 : 30),
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(-10, 0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  mentor.type.color.withOpacity(0.18),
                  AppColors.surface,
                  AppColors.jasmine.withOpacity(0.12),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(compact ? 26 : 30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Mentor Profile',
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Review mentor workload, details, and student assignments.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border.withOpacity(0.9), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ProfileCard(mentor: mentor),
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Professional Details',
                    children: <Widget>[
                      _DetailGrid(
                        children: <Widget>[
                          _InfoTile(label: 'Email', value: mentor.email),
                          _InfoTile(
                            label: 'Phone Number',
                            value: mentor.phoneNumber,
                          ),
                          _InfoTile(
                            label: 'Mentor Type',
                            value: mentor.type.label,
                          ),
                          _InfoTile(
                            label: mentor.type == MentorType.faculty
                                ? 'Department'
                                : 'Company',
                            value: mentor.primaryGroup,
                          ),
                          _InfoTile(
                            label: 'Designation',
                            value: mentor.designation,
                          ),
                          _InfoTile(
                            label: 'Status',
                            value: mentor.status.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Workload Overview',
                    children: <Widget>[
                      _DetailGrid(
                        children: <Widget>[
                          _InfoTile(
                            label: 'Assigned Students',
                            value: '${mentor.assignedStudents}',
                          ),
                          _InfoTile(
                            label: 'Active Internships',
                            value: '${mentor.activeInternships}',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Notes & Remarks',
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          mentor.notes,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.76),
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (mentor.studentPreview.isNotEmpty)
                    const SizedBox(height: 18),
                  if (mentor.studentPreview.isNotEmpty)
                    _DetailSection(
                      title: 'Student Preview',
                      children: mentor.studentPreview
                          .map(
                            (student) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  student,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border.withOpacity(0.92)),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(compact ? 26 : 30),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onClose,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onMessage(mentor),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coolSky,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onEdit(mentor),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Mentor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.aquamarine,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.mentor});

  final MentorRecord mentor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            mentor.type.color.withOpacity(0.18),
            AppColors.surface,
            AppColors.coolSky.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: mentor.type.color.withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  mentor.initials,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mentor.name,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 21),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mentor.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaChip(label: mentor.type.label, color: mentor.type.color),
              _MetaChip(label: mentor.status.label, color: mentor.status.color),
              _MetaChip(label: mentor.primaryGroup, color: AppColors.jasmine),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 17)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool singleColumn = constraints.maxWidth < 320;

        if (singleColumn) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: child,
                  ),
                )
                .toList(growable: false),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: child,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
