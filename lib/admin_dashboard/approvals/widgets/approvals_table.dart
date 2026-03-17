import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class ApprovalsTable extends StatelessWidget {
  const ApprovalsTable({
    super.key,
    required this.requests,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  final List<ApprovalRequest> requests;
  final ValueChanged<ApprovalRequest> onView;
  final ValueChanged<ApprovalRequest> onApprove;
  final ValueChanged<ApprovalRequest> onReject;

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
          final bool compact = constraints.maxWidth < 980;

          if (compact) {
            return Column(
              children: requests
                  .map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ApprovalRequestCard(
                        request: request,
                        onView: onView,
                        onApprove: onApprove,
                        onReject: onReject,
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
                  horizontal: 20,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: const <Widget>[
                    _HeaderCell(label: 'Name', flex: 3),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Role', flex: 2),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Department', flex: 2),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Request Type', flex: 3),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Request Date', flex: 2),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Status', flex: 2),
                    SizedBox(width: 18),
                    _HeaderCell(label: 'Actions', flex: 3),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...requests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ApprovalRequestRow(
                    request: request,
                    onView: onView,
                    onApprove: onApprove,
                    onReject: onReject,
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

class _ApprovalRequestRow extends StatefulWidget {
  const _ApprovalRequestRow({
    required this.request,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequest request;
  final ValueChanged<ApprovalRequest> onView;
  final ValueChanged<ApprovalRequest> onApprove;
  final ValueChanged<ApprovalRequest> onReject;

  @override
  State<_ApprovalRequestRow> createState() => _ApprovalRequestRowState();
}

class _ApprovalRequestRowState extends State<_ApprovalRequestRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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
            Expanded(
              flex: 3,
              child: _RequesterIdentity(request: widget.request),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: _DataText(
                widget.request.role.label,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: _DataText(
                widget.request.department,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(flex: 3, child: _DataText(widget.request.requestType)),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: _DataText(
                widget.request.requestDate,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _ApprovalStatusChip(status: widget.request.status),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 3,
              child: _RowActions(
                request: widget.request,
                onView: widget.onView,
                onApprove: widget.onApprove,
                onReject: widget.onReject,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalRequestCard extends StatefulWidget {
  const _ApprovalRequestCard({
    required this.request,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequest request;
  final ValueChanged<ApprovalRequest> onView;
  final ValueChanged<ApprovalRequest> onApprove;
  final ValueChanged<ApprovalRequest> onReject;

  @override
  State<_ApprovalRequestCard> createState() => _ApprovalRequestCardState();
}

class _ApprovalRequestCardState extends State<_ApprovalRequestCard> {
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
                Expanded(child: _RequesterIdentity(request: widget.request)),
                const SizedBox(width: 12),
                _ApprovalStatusChip(status: widget.request.status),
              ],
            ),
            const SizedBox(height: 16),
            _CompactInfoRow(label: 'Role', value: widget.request.role.label),
            _CompactInfoRow(
              label: 'Department',
              value: widget.request.department,
            ),
            _CompactInfoRow(
              label: 'Request Type',
              value: widget.request.requestType,
            ),
            _CompactInfoRow(
              label: 'Request Date',
              value: widget.request.requestDate,
            ),
            const SizedBox(height: 14),
            _RowActions(
              request: widget.request,
              onView: widget.onView,
              onApprove: widget.onApprove,
              onReject: widget.onReject,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequesterIdentity extends StatelessWidget {
  const _RequesterIdentity({required this.request});

  final ApprovalRequest request;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: request.role.color.withOpacity(0.16),
          ),
          alignment: Alignment.center,
          child: Text(
            request.initials,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                request.name,
                style: AppTextStyles.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                request.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.25,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        ),
      ],
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
        children: <Widget>[
          SizedBox(
            width: 104,
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

class _DataText extends StatelessWidget {
  const _DataText(this.value, {this.color = AppColors.textPrimary});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.tableCell.copyWith(color: color, height: 1.35),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.request,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    this.compact = false,
  });

  final ApprovalRequest request;
  final ValueChanged<ApprovalRequest> onView;
  final ValueChanged<ApprovalRequest> onApprove;
  final ValueChanged<ApprovalRequest> onReject;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool compactWidth = MediaQuery.sizeOf(context).width < 1220;

    final List<Widget> actions = <Widget>[
      _ActionButton(
        label: 'View',
        icon: Icons.visibility_rounded,
        color: AppColors.coolSky,
        onTap: () => onView(request),
        compact: compactWidth,
      ),
      _ActionButton(
        label: 'Approve',
        icon: Icons.check_circle_rounded,
        color: AppColors.aquamarine,
        onTap: () => onApprove(request),
        compact: compactWidth,
      ),
      _ActionButton(
        label: 'Reject',
        icon: Icons.cancel_rounded,
        color: AppColors.strawberryRed,
        onTap: () => onReject(request),
        compact: compactWidth,
      ),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: actions);
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
                  fontSize: compact ? 11.5 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalStatusChip extends StatelessWidget {
  const _ApprovalStatusChip({required this.status});

  final ApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.14)),
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

class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.requestType,
    required this.requestDate,
    required this.status,
    required this.notes,
    required this.profileSummary,
    this.assignedFaculty,
    this.assignedCompany,
  });

  final String id;
  final String name;
  final String email;
  final ApprovalRole role;
  final String department;
  final String requestType;
  final String requestDate;
  final ApprovalStatus status;
  final String notes;
  final String profileSummary;
  final String? assignedFaculty;
  final String? assignedCompany;

  String get initials {
    final List<String> parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  ApprovalRequest copyWith({ApprovalStatus? status}) {
    return ApprovalRequest(
      id: id,
      name: name,
      email: email,
      role: role,
      department: department,
      requestType: requestType,
      requestDate: requestDate,
      status: status ?? this.status,
      notes: notes,
      profileSummary: profileSummary,
      assignedFaculty: assignedFaculty,
      assignedCompany: assignedCompany,
    );
  }
}

enum ApprovalRole {
  student(label: 'Student', color: AppColors.coolSky),
  facultyMentor(label: 'Faculty Mentor', color: AppColors.aquamarine),
  companyMentor(label: 'Company Mentor', color: AppColors.tangerineDream),
  hod(label: 'HOD', color: AppColors.jasmine),
  principal(label: 'Principal', color: AppColors.strawberryRed);

  const ApprovalRole({required this.label, required this.color});

  final String label;
  final Color color;
}

enum ApprovalStatus {
  pending(
    label: 'Pending',
    color: AppColors.tangerineDream,
    backgroundColor: AppColors.peachSoft,
  ),
  approved(
    label: 'Approved',
    color: AppColors.aquamarine,
    backgroundColor: AppColors.secondarySoft,
  ),
  rejected(
    label: 'Rejected',
    color: AppColors.strawberryRed,
    backgroundColor: AppColors.dangerSoft,
  );

  const ApprovalStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}
