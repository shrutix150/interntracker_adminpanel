import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class TargetRoleSelector extends StatelessWidget {
  const TargetRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final NotificationAudienceRole selectedRole;
  final ValueChanged<NotificationAudienceRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: NotificationAudienceRole.values
          .map(
            (role) => _RoleTile(
              role: role,
              selected: role == selectedRole,
              onTap: () => onChanged(role),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final NotificationAudienceRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? role.color.withOpacity(0.16)
                : AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? role.color.withOpacity(0.28) : AppColors.border,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.72),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: role.color.withOpacity(selected ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(role.icon, size: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Text(
                role.label,
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

enum NotificationAudienceRole {
  allRoles(
    storageKey: 'all_roles',
    label: 'All roles',
    icon: Icons.hub_rounded,
    color: AppColors.coolSky,
  ),
  students(
    storageKey: 'students',
    label: 'Students',
    icon: Icons.school_rounded,
    color: AppColors.aquamarine,
  ),
  facultyMentors(
    storageKey: 'faculty_mentors',
    label: 'Faculty Mentors',
    icon: Icons.person_outline_rounded,
    color: AppColors.jasmine,
  ),
  companyMentors(
    storageKey: 'company_mentors',
    label: 'Company Mentors',
    icon: Icons.business_center_rounded,
    color: AppColors.tangerineDream,
  ),
  hods(
    storageKey: 'hods',
    label: 'HODs',
    icon: Icons.account_balance_rounded,
    color: AppColors.coolSky,
  ),
  principal(
    storageKey: 'principal',
    label: 'Principal',
    icon: Icons.workspace_premium_rounded,
    color: AppColors.strawberryRed,
  );

  const NotificationAudienceRole({
    required this.storageKey,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String storageKey;
  final String label;
  final IconData icon;
  final Color color;

  factory NotificationAudienceRole.fromStorage(String value) {
    final String normalized = value.trim().toLowerCase();
    for (final NotificationAudienceRole role in NotificationAudienceRole.values) {
      if (role.storageKey == normalized) {
        return role;
      }
    }
    return NotificationAudienceRole.allRoles;
  }
}
