import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class CompaniesTable extends StatelessWidget {
  const CompaniesTable({
    super.key,
    required this.companies,
    required this.onView,
    required this.onEdit,
    required this.onVerify,
  });

  final List<CompanyRecord> companies;
  final ValueChanged<CompanyRecord> onView;
  final ValueChanged<CompanyRecord> onEdit;
  final ValueChanged<CompanyRecord> onVerify;

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
              children: companies
                  .map(
                    (company) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CompanyCard(
                        company: company,
                        onView: onView,
                        onEdit: onEdit,
                        onVerify: onVerify,
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
                    _HeaderCell(label: 'Company', flex: 3),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Industry', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Location', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Company Mentor', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Assigned Students', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 16),
                    _HeaderCell(label: 'Actions', flex: 3),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...companies.map(
                (company) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CompanyRow(
                    company: company,
                    onView: onView,
                    onEdit: onEdit,
                    onVerify: onVerify,
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

class _CompanyRow extends StatefulWidget {
  const _CompanyRow({
    required this.company,
    required this.onView,
    required this.onEdit,
    required this.onVerify,
  });

  final CompanyRecord company;
  final ValueChanged<CompanyRecord> onView;
  final ValueChanged<CompanyRecord> onEdit;
  final ValueChanged<CompanyRecord> onVerify;

  @override
  State<_CompanyRow> createState() => _CompanyRowState();
}

class _CompanyRowState extends State<_CompanyRow> {
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
            Expanded(flex: 3, child: _CompanyIdentity(company: widget.company)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.company.industry)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.company.location)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _BodyText(widget.company.companyMentor)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _BodyText('${widget.company.assignedStudents}'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.company.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _ActionGroup(
                company: widget.company,
                onView: widget.onView,
                onEdit: widget.onEdit,
                onVerify: widget.onVerify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends StatefulWidget {
  const _CompanyCard({
    required this.company,
    required this.onView,
    required this.onEdit,
    required this.onVerify,
  });

  final CompanyRecord company;
  final ValueChanged<CompanyRecord> onView;
  final ValueChanged<CompanyRecord> onEdit;
  final ValueChanged<CompanyRecord> onVerify;

  @override
  State<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<_CompanyCard> {
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
                Expanded(child: _CompanyIdentity(company: widget.company)),
                const SizedBox(width: 12),
                _StatusChip(status: widget.company.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(label: 'Industry', value: widget.company.industry),
            _CompactInfoRow(label: 'Location', value: widget.company.location),
            _CompactInfoRow(
              label: 'Company Mentor',
              value: widget.company.companyMentor,
            ),
            _CompactInfoRow(
              label: 'Assigned Students',
              value: '${widget.company.assignedStudents}',
            ),
            const SizedBox(height: 16),
            _ActionGroup(
              company: widget.company,
              onView: widget.onView,
              onEdit: widget.onEdit,
              onVerify: widget.onVerify,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyIdentity extends StatelessWidget {
  const _CompanyIdentity({required this.company});

  final CompanyRecord company;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: company.status.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            company.initials,
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
                company.name,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                company.contactInfo,
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
    required this.company,
    required this.onView,
    required this.onEdit,
    required this.onVerify,
    this.compact = false,
  });

  final CompanyRecord company;
  final ValueChanged<CompanyRecord> onView;
  final ValueChanged<CompanyRecord> onEdit;
  final ValueChanged<CompanyRecord> onVerify;
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
          onTap: () => onView(company),
        ),
        _ActionButton(
          label: 'Edit',
          icon: Icons.edit_rounded,
          color: AppColors.jasmine,
          compact: compact,
          onTap: () => onEdit(company),
        ),
        _ActionButton(
          label: 'Verify',
          icon: Icons.verified_rounded,
          color: AppColors.aquamarine,
          compact: compact,
          onTap: () => onVerify(company),
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

  final CompanyStatus status;

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

class CompanyRecord {
  const CompanyRecord({
    required this.id,
    required this.name,
    required this.website,
    required this.contactEmail,
    required this.industry,
    required this.location,
    required this.companyMentor,
    required this.assignedStudents,
    required this.activeInternships,
    required this.status,
    required this.notes,
    required this.studentPreview,
  });

  final String id;
  final String name;
  final String website;
  final String contactEmail;
  final String industry;
  final String location;
  final String companyMentor;
  final int assignedStudents;
  final int activeInternships;
  final CompanyStatus status;
  final String notes;
  final List<String> studentPreview;

  String get initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get contactInfo => '$contactEmail | $website';

  CompanyRecord copyWith({CompanyStatus? status}) {
    return CompanyRecord(
      id: id,
      name: name,
      website: website,
      contactEmail: contactEmail,
      industry: industry,
      location: location,
      companyMentor: companyMentor,
      assignedStudents: assignedStudents,
      activeInternships: activeInternships,
      status: status ?? this.status,
      notes: notes,
      studentPreview: studentPreview,
    );
  }
}

enum CompanyStatus {
  active(
    label: 'Active',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  pending(
    label: 'Pending',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  ),
  inactive(
    label: 'Inactive',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  ),
  verified(
    label: 'Verified',
    color: AppColors.coolSky,
    backgroundColor: AppColors.primarySoft,
  );

  const CompanyStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}
