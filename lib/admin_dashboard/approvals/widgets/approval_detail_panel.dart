import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'approvals_table.dart';

class ApprovalDetailPanel extends StatelessWidget {
  const ApprovalDetailPanel({
    super.key,
    required this.request,
    required this.onClose,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequest request;
  final VoidCallback onClose;
  final ValueChanged<ApprovalRequest> onApprove;
  final ValueChanged<ApprovalRequest> onReject;

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
                  request.role.color.withOpacity(0.18),
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
                        'Request Details',
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Review the full request before taking action.',
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
                  _ProfileCard(request: request),
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Request Information',
                    children: <Widget>[
                      _DetailGrid(
                        children: <Widget>[
                          _InfoTile(label: 'Full Name', value: request.name),
                          _InfoTile(label: 'Email', value: request.email),
                          _InfoTile(label: 'Role', value: request.role.label),
                          _InfoTile(
                            label: 'Department',
                            value: request.department,
                          ),
                          _InfoTile(
                            label: 'Request Type',
                            value: request.requestType,
                          ),
                          _InfoTile(
                            label: 'Request Date',
                            value: request.requestDate,
                          ),
                          _InfoTile(
                            label: 'Current Status',
                            value: request.status.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (request.assignedFaculty != null ||
                      request.assignedCompany != null)
                    _DetailSection(
                      title: 'Assignment',
                      children: <Widget>[
                        _DetailGrid(
                          children: <Widget>[
                            if (request.assignedFaculty != null)
                              _InfoTile(
                                label: 'Assigned Faculty',
                                value: request.assignedFaculty!,
                              ),
                            if (request.assignedCompany != null)
                              _InfoTile(
                                label: 'Assigned Company',
                                value: request.assignedCompany!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  if (request.assignedFaculty != null ||
                      request.assignedCompany != null)
                    const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Profile Summary',
                    children: <Widget>[
                      Text(
                        request.profileSummary,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.76),
                          height: 1.55,
                        ),
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
                          request.notes,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.76),
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: () => onReject(request),
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.strawberryRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onApprove(request),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Approve Request'),
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
  const _ProfileCard({required this.request});

  final ApprovalRequest request;

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
            request.role.color.withOpacity(0.18),
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
                  color: request.role.color.withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  request.initials,
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
                      request.name,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 21),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.email,
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
              _MetaChip(label: request.role.label, color: request.role.color),
              _MetaChip(
                label: request.status.label,
                color: request.status.color,
              ),
              _MetaChip(label: request.department, color: AppColors.coolSky),
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
