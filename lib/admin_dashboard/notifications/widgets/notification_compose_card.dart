import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'target_role_selector.dart';

class NotificationComposeCard extends StatelessWidget {
  const NotificationComposeCard({
    super.key,
    required this.title,
    required this.message,
    required this.selectedRole,
    required this.selectedDepartment,
    required this.selectedPriority,
    required this.departmentOptions,
    required this.onTitleChanged,
    required this.onMessageChanged,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onPriorityChanged,
    required this.onSend,
  });

  final String title;
  final String message;
  final NotificationAudienceRole selectedRole;
  final String selectedDepartment;
  final NotificationPriority selectedPriority;
  final List<String> departmentOptions;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onMessageChanged;
  final ValueChanged<NotificationAudienceRole> onRoleChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<NotificationPriority> onPriorityChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Compose Announcement',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            'Send targeted updates across the internship ecosystem with clear audience controls.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            key: ValueKey<String>('title-$title'),
            initialValue: title,
            onChanged: onTitleChanged,
            decoration: const InputDecoration(
              labelText: 'Notification title',
              hintText: 'Enter a short announcement title',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: ValueKey<String>('message-$message'),
            initialValue: message,
            onChanged: onMessageChanged,
            minLines: 5,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Write the message that will be sent to users',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Target Role',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          TargetRoleSelector(
            selectedRole: selectedRole,
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 720;

              if (compact) {
                return Column(
                  children: <Widget>[
                    _DropdownField<String>(
                      label: 'Department',
                      value: selectedDepartment,
                      items: departmentOptions,
                      itemLabelBuilder: (item) => item,
                      onChanged: onDepartmentChanged,
                    ),
                    const SizedBox(height: 14),
                    _DropdownField<NotificationPriority>(
                      label: 'Priority',
                      value: selectedPriority,
                      items: NotificationPriority.values,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: onPriorityChanged,
                    ),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(
                    child: _DropdownField<String>(
                      label: 'Department',
                      value: selectedDepartment,
                      items: departmentOptions,
                      itemLabelBuilder: (item) => item,
                      onChanged: onDepartmentChanged,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _DropdownField<NotificationPriority>(
                      label: 'Priority',
                      value: selectedPriority,
                      items: NotificationPriority.values,
                      itemLabelBuilder: (item) => item.label,
                      onChanged: onPriorityChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPriority.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedPriority.color.withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    'Audience: ${selectedRole.label} | ${selectedDepartment == 'All departments' ? 'All departments' : selectedDepartment}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coolSky,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.background,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabelBuilder(item),
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

enum NotificationPriority {
  normal(storageKey: 'normal', label: 'Normal', color: AppColors.coolSky),
  important(
    storageKey: 'important',
    label: 'Important',
    color: AppColors.tangerineDream,
  ),
  urgent(storageKey: 'urgent', label: 'Urgent', color: AppColors.strawberryRed);

  const NotificationPriority({
    required this.storageKey,
    required this.label,
    required this.color,
  });

  final String storageKey;
  final String label;
  final Color color;

  factory NotificationPriority.fromStorage(String value) {
    final String normalized = value.trim().toLowerCase();
    for (final NotificationPriority priority in NotificationPriority.values) {
      if (priority.storageKey == normalized) {
        return priority;
      }
    }
    return NotificationPriority.normal;
  }
}
