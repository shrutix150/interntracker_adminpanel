import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class MentorsTable extends StatelessWidget {
  const MentorsTable({
    super.key,
    required this.mentors,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final List<MentorRecord> mentors;
  final ValueChanged<MentorRecord> onView;
  final ValueChanged<MentorRecord> onEdit;
  final ValueChanged<MentorRecord> onMessage;

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
              children: mentors
                  .map(
                    (mentor) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MentorCard(
                        mentor: mentor,
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
                    _HeaderCell(label: 'Mentor', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Type', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Department / Company', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Phone', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 3),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...mentors.map(
                (mentor) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MentorRow(
                    mentor: mentor,
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

class _MentorRow extends StatefulWidget {
  const _MentorRow({
    required this.mentor,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final MentorRecord mentor;
  final ValueChanged<MentorRecord> onView;
  final ValueChanged<MentorRecord> onEdit;
  final ValueChanged<MentorRecord> onMessage;

  @override
  State<_MentorRow> createState() => _MentorRowState();
}

class _MentorRowState extends State<_MentorRow> {
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
            Expanded(flex: 3, child: _MentorIdentity(mentor: widget.mentor)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.mentor.type.label)),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _BodyText(widget.mentor.primaryGroup)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.mentor.phoneNumber)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.mentor.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _ActionGroup(
                mentor: widget.mentor,
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

class _MentorCard extends StatefulWidget {
  const _MentorCard({
    required this.mentor,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final MentorRecord mentor;
  final ValueChanged<MentorRecord> onView;
  final ValueChanged<MentorRecord> onEdit;
  final ValueChanged<MentorRecord> onMessage;

  @override
  State<_MentorCard> createState() => _MentorCardState();
}

class _MentorCardState extends State<_MentorCard> {
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
                Expanded(child: _MentorIdentity(mentor: widget.mentor)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.mentor.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(label: 'Type', value: widget.mentor.type.label),
            _CompactInfoRow(
              label: 'Department / Company',
              value: widget.mentor.primaryGroup,
            ),
            _CompactInfoRow(label: 'Phone', value: widget.mentor.phoneNumber),
            const SizedBox(height: 16),
            _ActionGroup(
              mentor: widget.mentor,
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

class _MentorIdentity extends StatelessWidget {
  const _MentorIdentity({required this.mentor});

  final MentorRecord mentor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: mentor.type.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            mentor.initials,
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
                mentor.name,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                mentor.email,
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

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.mentor,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
    this.compact = false,
  });

  final MentorRecord mentor;
  final ValueChanged<MentorRecord> onView;
  final ValueChanged<MentorRecord> onEdit;
  final ValueChanged<MentorRecord> onMessage;
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
          onTap: () => onView(mentor),
        ),
        _ActionButton(
          label: 'Edit',
          icon: Icons.edit_rounded,
          color: AppColors.jasmine,
          compact: compact,
          onTap: () => onEdit(mentor),
        ),
        _ActionButton(
          label: 'Message',
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.aquamarine,
          compact: compact,
          onTap: () => onMessage(mentor),
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

  final MentorStatus status;

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
            width: 126,
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

class MentorRecord {
  const MentorRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.department,
    required this.company,
    required this.phoneNumber,
    required this.employeeId,
    required this.designation,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final MentorType type;
  final String? department;
  final String? company;
  final String phoneNumber;
  final String employeeId;
  final String designation;
  final MentorStatus status;
  final DateTime? createdAt;

  String get initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get primaryGroup => type == MentorType.faculty
      ? (department ?? 'Unassigned Department')
      : (company ?? 'Unassigned Company');

  String get joinedOnLabel {
    if (createdAt == null) {
      return 'Not available';
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

    return '${createdAt!.day.toString().padLeft(2, '0')} '
        '${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  factory MentorRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final String role = _readString(data['role'], fallback: 'mentor')
        .toLowerCase();

    return MentorRecord(
      id: doc.id,
      name: _readString(
        data['name'] ?? data['fullName'] ?? data['displayName'],
        fallback: 'Unknown Mentor',
      ),
      email: _readString(data['email'], fallback: 'No email'),
      type: MentorType.fromFirestore(role),
      department: _readNullableString(<dynamic>[
        data['department'],
        data['branch'],
        data['facultyDepartment'],
      ]),
      company: _readNullableString(<dynamic>[
        data['companyName'],
        data['company'],
        data['organization'],
      ]),
      phoneNumber: _readString(
        data['phoneNumber'] ?? data['phone'] ?? data['mobileNumber'],
        fallback: 'Not provided',
      ),
      employeeId: _readString(
        data['employeeId'] ?? data['staffId'] ?? data['facultyId'],
        fallback: 'Not provided',
      ),
      designation: _readString(
        data['designation'] ?? data['jobTitle'] ?? data['position'],
        fallback: 'Not provided',
      ),
      status: MentorStatus.fromFirestore(
        status: data['status'],
        isApproved: data['isApproved'],
      ),
      createdAt: _readDateTime(
        data['createdAt'] ?? data['updatedAt'] ?? data['requestDate'],
      ),
    );
  }

  static String _readString(dynamic value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }

    final String normalized = value.toString().trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static String? _readNullableString(List<dynamic> values) {
    for (final dynamic value in values) {
      if (value == null) {
        continue;
      }

      final String normalized = value.toString().trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

enum MentorType {
  faculty(label: 'Faculty Mentor', color: AppColors.coolSky),
  company(label: 'Company Mentor', color: AppColors.aquamarine);

  const MentorType({required this.label, required this.color});

  final String label;
  final Color color;

  factory MentorType.fromFirestore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'faculty':
        return MentorType.faculty;
      default:
        return MentorType.company;
    }
  }
}

enum MentorStatus {
  active(
    label: 'Active',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  pending(
    label: 'Pending',
    color: AppColors.jasmine,
    backgroundColor: AppColors.peachSoft,
  ),
  inactive(
    label: 'Inactive',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  );

  const MentorStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  factory MentorStatus.fromFirestore({
    required dynamic status,
    required dynamic isApproved,
  }) {
    final String normalized = (status ?? '').toString().trim().toLowerCase();
    final bool approved = isApproved == true;

    if (normalized == 'rejected' ||
        normalized == 'inactive' ||
        normalized == 'disabled') {
      return MentorStatus.inactive;
    }
    if (normalized == 'pending' ||
        normalized == 'requested' ||
        normalized == 'waiting' ||
        (!approved && normalized != 'approved')) {
      return MentorStatus.pending;
    }
    return MentorStatus.active;
  }
}
