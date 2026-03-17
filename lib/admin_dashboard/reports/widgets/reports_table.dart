import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class ReportsTable extends StatelessWidget {
  const ReportsTable({
    super.key,
    required this.reports,
    required this.onView,
    required this.onReview,
    required this.onRequestCorrection,
  });

  final List<WeeklyReportRecord> reports;
  final ValueChanged<WeeklyReportRecord> onView;
  final ValueChanged<WeeklyReportRecord> onReview;
  final ValueChanged<WeeklyReportRecord> onRequestCorrection;

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
          final bool compact = constraints.maxWidth < 1120;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reports
                  .map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReportCard(
                        report: report,
                        onView: onView,
                        onReview: onReview,
                        onRequestCorrection: onRequestCorrection,
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
                    _HeaderCell(label: 'Week', flex: 1),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Faculty Mentor', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Company Mentor', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Submitted Date', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 3),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...reports.map(
                (report) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReportRow(
                    report: report,
                    onView: onView,
                    onReview: onReview,
                    onRequestCorrection: onRequestCorrection,
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

class _ReportRow extends StatefulWidget {
  const _ReportRow({
    required this.report,
    required this.onView,
    required this.onReview,
    required this.onRequestCorrection,
  });

  final WeeklyReportRecord report;
  final ValueChanged<WeeklyReportRecord> onView;
  final ValueChanged<WeeklyReportRecord> onReview;
  final ValueChanged<WeeklyReportRecord> onRequestCorrection;

  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
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
            Expanded(flex: 3, child: _StudentIdentity(report: widget.report)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.report.department)),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _BodyText(widget.report.week)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.report.facultyMentor)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.report.companyMentor)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.report.submittedDate)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.report.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _ActionGroup(
                report: widget.report,
                onView: widget.onView,
                onReview: widget.onReview,
                onRequestCorrection: widget.onRequestCorrection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  const _ReportCard({
    required this.report,
    required this.onView,
    required this.onReview,
    required this.onRequestCorrection,
  });

  final WeeklyReportRecord report;
  final ValueChanged<WeeklyReportRecord> onView;
  final ValueChanged<WeeklyReportRecord> onReview;
  final ValueChanged<WeeklyReportRecord> onRequestCorrection;

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
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
                Expanded(child: _StudentIdentity(report: widget.report)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.report.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(
              label: 'Department',
              value: widget.report.department,
            ),
            _CompactInfoRow(label: 'Week', value: widget.report.week),
            _CompactInfoRow(
              label: 'Faculty Mentor',
              value: widget.report.facultyMentor,
            ),
            _CompactInfoRow(
              label: 'Company Mentor',
              value: widget.report.companyMentor,
            ),
            _CompactInfoRow(
              label: 'Submitted',
              value: widget.report.submittedDate,
            ),
            const SizedBox(height: 16),
            _ActionGroup(
              report: widget.report,
              onView: widget.onView,
              onReview: widget.onReview,
              onRequestCorrection: widget.onRequestCorrection,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.report});

  final WeeklyReportRecord report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: report.status.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            report.initials,
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
                report.studentName,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                '${report.rollNumber} | ${report.studentEmail}',
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
    required this.report,
    required this.onView,
    required this.onReview,
    required this.onRequestCorrection,
    this.compact = false,
  });

  final WeeklyReportRecord report;
  final ValueChanged<WeeklyReportRecord> onView;
  final ValueChanged<WeeklyReportRecord> onReview;
  final ValueChanged<WeeklyReportRecord> onRequestCorrection;
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
          onTap: () => onView(report),
        ),
        _ActionButton(
          label: 'Review',
          icon: Icons.fact_check_rounded,
          color: AppColors.aquamarine,
          compact: compact,
          onTap: () => onReview(report),
        ),
        _ActionButton(
          label: 'Request Correction',
          icon: Icons.edit_note_rounded,
          color: AppColors.tangerineDream,
          compact: compact,
          onTap: () => onRequestCorrection(report),
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
            horizontal: compact ? 10 : 11,
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

  final ReportStatus status;

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
            width: 118,
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

class WeeklyReportRecord {
  const WeeklyReportRecord({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.week,
    required this.reportTitle,
    required this.submittedDate,
    required this.status,
    required this.facultyMentor,
    required this.companyMentor,
    required this.summary,
    required this.feedback,
  });

  final String id;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String week;
  final String reportTitle;
  final String submittedDate;
  final ReportStatus status;
  final String facultyMentor;
  final String companyMentor;
  final String summary;
  final String feedback;

  String get initials {
    final List<String> parts = studentName.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  WeeklyReportRecord copyWith({ReportStatus? status, String? feedback}) {
    return WeeklyReportRecord(
      id: id,
      studentName: studentName,
      studentEmail: studentEmail,
      rollNumber: rollNumber,
      department: department,
      week: week,
      reportTitle: reportTitle,
      submittedDate: submittedDate,
      status: status ?? this.status,
      facultyMentor: facultyMentor,
      companyMentor: companyMentor,
      summary: summary,
      feedback: feedback ?? this.feedback,
    );
  }
}

enum ReportStatus {
  pending(
    label: 'Pending',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  ),
  reviewed(
    label: 'Reviewed',
    color: AppColors.coolSky,
    backgroundColor: AppColors.primarySoft,
  ),
  correctionsRequested(
    label: 'Corrections Requested',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  ),
  approved(
    label: 'Approved',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  );

  const ReportStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}
