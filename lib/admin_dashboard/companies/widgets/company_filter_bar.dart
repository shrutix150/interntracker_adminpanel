import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'companies_table.dart';

class CompanyFilterBar extends StatelessWidget {
  const CompanyFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedIndustry,
    required this.selectedLocation,
    required this.searchQuery,
    required this.industryOptions,
    required this.locationOptions,
    required this.onStatusChanged,
    required this.onIndustryChanged,
    required this.onLocationChanged,
    required this.onSearchChanged,
    required this.onReset,
  });

  final CompanyStatus? selectedStatus;
  final String? selectedIndustry;
  final String? selectedLocation;
  final String searchQuery;
  final List<String> industryOptions;
  final List<String> locationOptions;
  final ValueChanged<CompanyStatus?> onStatusChanged;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onLocationChanged;
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
            _FilterDropdown<CompanyStatus>(
              label: 'Status',
              value: selectedStatus,
              allLabel: 'All statuses',
              items: CompanyStatus.values,
              itemLabelBuilder: (item) => item.label,
              onChanged: onStatusChanged,
              compactLabel: compactFieldLabels,
            ),
            _FilterDropdown<String>(
              label: 'Industry',
              value: selectedIndustry,
              allLabel: 'All industries',
              items: industryOptions,
              itemLabelBuilder: (item) => item,
              onChanged: onIndustryChanged,
              compactLabel: compactFieldLabels,
            ),
            _FilterDropdown<String>(
              label: 'Location',
              value: selectedLocation,
              allLabel: 'All locations',
              items: locationOptions,
              itemLabelBuilder: (item) => item,
              onChanged: onLocationChanged,
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
              Flexible(flex: 2, child: controls[0]),
              const SizedBox(width: 12),
              Flexible(flex: 3, child: controls[1]),
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
            hintText: 'Search company name, mentor, or website',
            filled: true,
            fillColor: AppColors.background,
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }
}
