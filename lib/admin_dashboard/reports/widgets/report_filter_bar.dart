import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'reports_table.dart';

class ReportFilterBar extends StatelessWidget {
  const ReportFilterBar({
    super.key,
    required this.selectedDepartment,
    required this.selectedStatus,
    required this.selectedWeek,
    required this.searchQuery,
    required this.departmentOptions,
    required this.weekOptions,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
    required this.onWeekChanged,
    required this.onSearchChanged,
    required this.onReset,
  });

  final String? selectedDepartment;
  final ReportStatus? selectedStatus;
  final String? selectedWeek;
  final String searchQuery;
  final List<String> departmentOptions;
  final List<String> weekOptions;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<ReportStatus?> onStatusChanged;
  final ValueChanged<String?> onWeekChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final bool compactFieldLabels = MediaQuery.sizeOf(context).width < 860;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 1180;
          final double twoColWidth = constraints.maxWidth > 760
              ? (constraints.maxWidth - 14) / 2
              : constraints.maxWidth;

          final List<Widget> controls = <Widget>[
            _FilterDropdown<String>(
              label: 'Department',
              value: selectedDepartment,
              allLabel: 'All departments',
              items: departmentOptions,
              itemLabelBuilder: (item) => item,
              onChanged: onDepartmentChanged,
              compactLabel: compactFieldLabels,
            ),
            _FilterDropdown<ReportStatus>(
              label: 'Status',
              value: selectedStatus,
              allLabel: 'All statuses',
              items: ReportStatus.values,
              itemLabelBuilder: (item) => item.label,
              onChanged: onStatusChanged,
              compactLabel: compactFieldLabels,
            ),
            _FilterDropdown<String>(
              label: 'Week',
              value: selectedWeek,
              allLabel: 'All weeks',
              items: weekOptions,
              itemLabelBuilder: (item) => item,
              onChanged: onWeekChanged,
              compactLabel: compactFieldLabels,
            ),
            _SearchField(
              value: searchQuery,
              onChanged: onSearchChanged,
              compactLabel: compactFieldLabels,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ];

          if (compact) {
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: <Widget>[
                SizedBox(width: twoColWidth, child: controls[0]),
                SizedBox(width: twoColWidth, child: controls[1]),
                SizedBox(width: twoColWidth, child: controls[2]),
                SizedBox(width: twoColWidth, child: controls[3]),
                controls[4],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(flex: 3, child: controls[0]),
              const SizedBox(width: 12),
              Flexible(flex: 2, child: controls[1]),
              const SizedBox(width: 12),
              Flexible(flex: 2, child: controls[2]),
              const SizedBox(width: 12),
              Flexible(flex: 3, child: controls[3]),
              const SizedBox(width: 12),
              Flexible(child: controls[4]),
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.allLabel,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    required this.compactLabel,
  });

  final String label;
  final T? value;
  final String allLabel;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final bool compactLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: compactLabel ? 12 : 13,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          items: <DropdownMenuItem<T>>[
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                allLabel,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.value,
    required this.onChanged,
    required this.compactLabel,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool compactLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Search',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: compactLabel ? 12 : 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey<String>(value),
          initialValue: value,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search report title, student, or roll number',
            filled: true,
            fillColor: AppColors.background,
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }
}
