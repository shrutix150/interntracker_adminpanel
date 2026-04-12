import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../models/student_record.dart';

class StudentsTable extends StatelessWidget {
  const StudentsTable({
    super.key,
    required this.students,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final List<StudentRecord> students;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

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
              children: students
                  .map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StudentCard(
                        student: student,
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
                    _HeaderCell(label: 'Student', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Department', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Year', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Company', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Faculty Mentor', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Attendance', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Progress', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentRow(
                    student: student,
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

class _StudentRow extends StatefulWidget {
  const _StudentRow({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
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
            Expanded(flex: 3, child: _StudentIdentity(student: widget.student)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.department)),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _BodyText(widget.student.year.label)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.company)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.student.facultyMentor)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.student.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _BodyText('${widget.student.attendance}%'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _ProgressCell(progress: widget.student.progress),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _ActionGroup(
                student: widget.student,
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

class _StudentCard extends StatefulWidget {
  const _StudentCard({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
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
                Expanded(child: _StudentIdentity(student: widget.student)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.student.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(
              label: 'Department',
              value: widget.student.department,
            ),
            _CompactInfoRow(label: 'Year', value: widget.student.year.label),
            _CompactInfoRow(label: 'Company', value: widget.student.company),
            _CompactInfoRow(
              label: 'Faculty Mentor',
              value: widget.student.facultyMentor,
            ),
            _CompactInfoRow(
              label: 'Attendance',
              value: '${widget.student.attendance}%',
            ),
            const SizedBox(height: 8),
            _ProgressCell(progress: widget.student.progress),
            const SizedBox(height: 16),
            _ActionGroup(
              student: widget.student,
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

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.student});

  final StudentRecord student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: student.status.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            student.initials,
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
                student.name,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                '${student.rollNumber} | ${student.email}',
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

class _ProgressCell extends StatelessWidget {
  const _ProgressCell({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final Color barColor = progress >= 80
        ? AppColors.aquamarine
        : progress >= 60
        ? AppColors.coolSky
        : AppColors.tangerineDream;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$progress%',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onMessage,
    this.compact = false,
  });

  final StudentRecord student;
  final ValueChanged<StudentRecord> onView;
  final ValueChanged<StudentRecord> onEdit;
  final ValueChanged<StudentRecord> onMessage;
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
          onTap: () => onView(student),
        ),
        _ActionButton(
          label: 'Edit',
          icon: Icons.edit_rounded,
          color: AppColors.jasmine,
          compact: compact,
          onTap: () => onEdit(student),
        ),
        _ActionButton(
          label: 'Delete',
          icon: Icons.delete_outline,
          color: AppColors.strawberryRed,
          compact: compact,
          onTap: () => onMessage(student),
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

  final StudentInternshipStatus status;

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
            width: 110,
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
