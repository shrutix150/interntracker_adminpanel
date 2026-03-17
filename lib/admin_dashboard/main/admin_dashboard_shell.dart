import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'admin_navigation_item.dart';
import 'admin_sidebar.dart';
import 'admin_topbar.dart';
import 'dashboard_router.dart';

class AdminDashboardShell extends StatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  AdminNavigationItem _selectedItem = AdminNavigationItem.dashboard;
  final LayerLink _notificationBellLink = LayerLink();
  bool _showQuickAlerts = false;

  @override
  Widget build(BuildContext context) {
    final bool showCompactSidebar = MediaQuery.sizeOf(context).width < 1180;
    final double sidebarWidth = showCompactSidebar ? 104 : 288;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.background,
              AppColors.coolSky.withOpacity(0.05),
              AppColors.aquamarine.withOpacity(0.04),
            ],
          ),
        ),
        child: Row(
          children: <Widget>[
            if (showCompactSidebar)
              _CompactRail(
                selectedItem: _selectedItem,
                onItemSelected: _handleNavigationSelection,
                width: sidebarWidth,
              )
            else
              AdminSidebar(
                width: sidebarWidth,
                selectedItem: _selectedItem,
                onItemSelected: _handleNavigationSelection,
              ),
            Expanded(
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: <Widget>[
                          AdminTopbar(
                            title: _selectedItem.title,
                            onNotificationTap: _toggleQuickAlerts,
                            notificationBellLink: _notificationBellLink,
                            notificationsOpen: _showQuickAlerts,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final curved = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                );

                                return FadeTransition(
                                  opacity: curved,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.03, 0),
                                      end: Offset.zero,
                                    ).animate(curved),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_selectedItem.routeIndex),
                                child: DashboardRouter(
                                  selectedItem: _selectedItem,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showQuickAlerts) ...<Widget>[
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _closeQuickAlerts,
                          behavior: HitTestBehavior.translucent,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        right: 24,
                        child: CompositedTransformFollower(
                          link: _notificationBellLink,
                          showWhenUnlinked: false,
                          targetAnchor: Alignment.bottomRight,
                          followerAnchor: Alignment.topRight,
                          offset: const Offset(0, 12),
                          child: _QuickAlertsPanel(
                            onViewAll: _openNotificationsScreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigationSelection(AdminNavigationItem item) {
    setState(() {
      _selectedItem = item;
      _showQuickAlerts = false;
    });
  }

  void _toggleQuickAlerts() {
    setState(() {
      _showQuickAlerts = !_showQuickAlerts;
    });
  }

  void _closeQuickAlerts() {
    if (!_showQuickAlerts) {
      return;
    }

    setState(() {
      _showQuickAlerts = false;
    });
  }

  void _openNotificationsScreen() {
    setState(() {
      _selectedItem = AdminNavigationItem.notifications;
      _showQuickAlerts = false;
    });
  }
}

class _CompactRail extends StatelessWidget {
  const _CompactRail({
    required this.selectedItem,
    required this.onItemSelected,
    required this.width,
  });

  final AdminNavigationItem selectedItem;
  final ValueChanged<AdminNavigationItem> onItemSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Column(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[AppColors.coolSky, AppColors.aquamarine],
                  ),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: AdminNavigationItem.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = AdminNavigationItem.values[index];
                    final bool isSelected = item == selectedItem;

                    return Tooltip(
                      message: item.title,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onItemSelected(item),
                          borderRadius: BorderRadius.circular(18),
                          child: Ink(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isSelected
                                  ? AppColors.primarySoft
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.coolSky.withOpacity(0.22)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : (item == AdminNavigationItem.logout
                                        ? AppColors.strawberryRed
                                        : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAlertsPanel extends StatelessWidget {
  const _QuickAlertsPanel({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 356,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Quick Alerts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recent system updates',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ..._quickAlerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickAlertItem(alert: alert),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
                  foregroundColor: AppColors.coolSky,
                ),
                child: const Text(
                  'View all notifications',
                  style: TextStyle(
                    color: AppColors.coolSky,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAlertItem extends StatefulWidget {
  const _QuickAlertItem({required this.alert});

  final _QuickAlertData alert;

  @override
  State<_QuickAlertItem> createState() => _QuickAlertItemState();
}

class _QuickAlertItemState extends State<_QuickAlertItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.hover : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? widget.alert.color.withOpacity(0.18)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.alert.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.alert.icon,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.alert.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.alert.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.alert.time,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAlertData {
  const _QuickAlertData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
}

const List<_QuickAlertData> _quickAlerts = <_QuickAlertData>[
  _QuickAlertData(
    title: 'New student registration pending approval',
    subtitle: 'One profile is waiting for admin review in Approvals.',
    time: '5 min ago',
    icon: Icons.person_add_alt_1_rounded,
    color: AppColors.coolSky,
  ),
  _QuickAlertData(
    title: 'Weekly report submitted by Aditi Sharma',
    subtitle: 'Week 6 report has been added to the Reports queue.',
    time: '12 min ago',
    icon: Icons.description_rounded,
    color: AppColors.aquamarine,
  ),
  _QuickAlertData(
    title: 'Company mentor verification request pending',
    subtitle: 'A new company mentor profile is awaiting verification.',
    time: '22 min ago',
    icon: Icons.verified_user_rounded,
    color: AppColors.tangerineDream,
  ),
  _QuickAlertData(
    title: 'Low attendance alert for one student',
    subtitle: 'Attendance threshold dropped below the expected range.',
    time: '38 min ago',
    icon: Icons.warning_amber_rounded,
    color: AppColors.strawberryRed,
  ),
  _QuickAlertData(
    title: 'Internship deadline reminder sent',
    subtitle: 'A scheduled reminder was delivered to final-year students.',
    time: '1 hr ago',
    icon: Icons.schedule_send_rounded,
    color: AppColors.jasmine,
  ),
];
