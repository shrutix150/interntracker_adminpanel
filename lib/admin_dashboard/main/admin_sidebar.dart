import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'admin_navigation_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    this.width = 288,
  });

  final AdminNavigationItem selectedItem;
  final ValueChanged<AdminNavigationItem> onItemSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.sidebarBackground, AppColors.surface],
        ),
        border: Border(
          right: BorderSide(color: AppColors.border.withOpacity(0.9)),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 34,
            offset: Offset(12, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BrandHeader(
                onPressed: () => onItemSelected(AdminNavigationItem.dashboard),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: AdminNavigationItem.primaryItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = AdminNavigationItem.primaryItems[index];
                    return _SidebarItemTile(
                      item: item,
                      isSelected: item == selectedItem,
                      onTap: () => onItemSelected(item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _SidebarItemTile(
                item: AdminNavigationItem.logout,
                isSelected: selectedItem == AdminNavigationItem.logout,
                onTap: () => onItemSelected(AdminNavigationItem.logout),
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.coolSky.withOpacity(0.18),
              AppColors.aquamarine.withOpacity(0.16),
              AppColors.jasmine.withOpacity(0.24),
            ],
          ),
          border: Border.all(color: AppColors.surface.withOpacity(0.8)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppColors.coolSky, AppColors.aquamarine],
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'InternTracker Admin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control Center',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItemTile extends StatefulWidget {
  const _SidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isLogout = false,
  });

  final AdminNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  State<_SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<_SidebarItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isSelected;
    final bool isLogout = widget.isLogout;

    final Color iconColor = isLogout
        ? AppColors.strawberryRed
        : isActive
        ? AppColors.textPrimary
        : (_isHovered ? AppColors.coolSky : AppColors.textSecondary);

    final Color textColor = isLogout
        ? AppColors.strawberryRed
        : isActive
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    AppColors.coolSky.withOpacity(0.2),
                    AppColors.aquamarine.withOpacity(0.18),
                    AppColors.jasmine.withOpacity(0.26),
                  ],
                )
              : null,
          color: !isActive && _isHovered ? AppColors.hover : Colors.transparent,
          border: Border.all(
            color: isActive
                ? AppColors.surface.withOpacity(0.95)
                : (_isHovered
                      ? AppColors.coolSky.withOpacity(0.16)
                      : Colors.transparent),
          ),
          boxShadow: isActive
              ? const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isActive
                          ? AppColors.surface.withOpacity(0.72)
                          : (_isHovered
                                ? AppColors.surface.withOpacity(0.82)
                                : AppColors.surface.withOpacity(0.54)),
                    ),
                    child: Icon(widget.item.icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isActive ? 1 : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          width: 8,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                AppColors.coolSky,
                                AppColors.aquamarine,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
