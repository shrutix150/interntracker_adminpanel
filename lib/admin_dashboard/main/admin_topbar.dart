import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class AdminTopbar extends StatelessWidget {
  const AdminTopbar({
    super.key,
    required this.title,
    required this.onNotificationTap,
    required this.notificationBellLink,
    this.notificationsOpen = false,
  });

  final String title;
  final VoidCallback onNotificationTap;
  final LayerLink notificationBellLink;
  final bool notificationsOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 980;
        final bool isUltraCompact = constraints.maxWidth < 760;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 18 : 24,
            vertical: isCompact ? 16 : 18,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TopbarHeading(title: title),
                    const SizedBox(height: 16),
                    const _SearchField(),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _NotificationAction(
                          onPressed: onNotificationTap,
                          layerLink: notificationBellLink,
                          isActive: notificationsOpen,
                        ),
                        _ProfileCard(),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(flex: 4, child: _TopbarHeading(title: title)),
                    const SizedBox(width: 18),
                    const Expanded(flex: 5, child: _SearchField()),
                    const SizedBox(width: 16),
                    _NotificationAction(
                      onPressed: onNotificationTap,
                      layerLink: notificationBellLink,
                      isActive: notificationsOpen,
                    ),
                    SizedBox(width: isUltraCompact ? 10 : 12),
                    Flexible(
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: _ProfileCard(),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _TopbarHeading extends StatelessWidget {
  const _TopbarHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.pageTitle),
        const SizedBox(height: 4),
        Text(
          'Monitor operations, insights, and intern workflows in one place.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 820;

    return Container(
      height: compact ? 52 : 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search students, approvals, companies, or reports',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          prefixIcon: Container(
            margin: EdgeInsets.all(compact ? 8 : 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.coolSky,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Ctrl K',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationAction extends StatefulWidget {
  const _NotificationAction({
    required this.onPressed,
    required this.layerLink,
    required this.isActive,
  });

  final VoidCallback onPressed;
  final LayerLink layerLink;
  final bool isActive;

  @override
  State<_NotificationAction> createState() => _NotificationActionState();
}

class _NotificationActionState extends State<_NotificationAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _hovered || widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CompositedTransformTarget(
        link: widget.layerLink,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: highlighted ? AppColors.hover : AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? AppColors.coolSky.withOpacity(0.35)
                  : AppColors.border,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IconButton(
                onPressed: widget.onPressed,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              Positioned(
                top: 12,
                right: 13,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.strawberryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 1180;

    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 52 : 54,
        maxWidth: compact ? 188 : 210,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: compact ? 36 : 38,
            height: compact ? 36 : 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.tangerineDream, AppColors.jasmine],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'A',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Admin User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Super Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
