import 'package:flutter/material.dart';

enum AdminNavigationItem {
  dashboard(
    routeIndex: 0,
    title: 'Dashboard',
    icon: Icons.space_dashboard_rounded,
  ),
  approvals(
    routeIndex: 1,
    title: 'Approvals',
    icon: Icons.verified_user_rounded,
  ),
  students(routeIndex: 2, title: 'Students', icon: Icons.school_rounded),
  mentors(routeIndex: 3, title: 'Mentors', icon: Icons.groups_rounded),
  companies(
    routeIndex: 4,
    title: 'Companies',
    icon: Icons.business_center_rounded,
  ),
  notifications(
    routeIndex: 5,
    title: 'Notifications',
    icon: Icons.notifications_outlined,
  ),
  settings(routeIndex: 6, title: 'Settings', icon: Icons.settings_rounded),
  logout(routeIndex: 7, title: 'Logout', icon: Icons.logout_rounded);

  const AdminNavigationItem({
    required this.routeIndex,
    required this.title,
    required this.icon,
  });

  final int routeIndex;
  final String title;
  final IconData icon;

  static List<AdminNavigationItem> get primaryItems => values
      .where((item) => item != AdminNavigationItem.logout)
      .toList(growable: false);

  static AdminNavigationItem fromIndex(int index) {
    return values.firstWhere(
      (item) => item.routeIndex == index,
      orElse: () => AdminNavigationItem.dashboard,
    );
  }
}
