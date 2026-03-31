import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

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
  final DateTime? requestDate;
  final ApprovalStatus status;
  final String notes;
  final String profileSummary;
  final String? assignedFaculty;
  final String? assignedCompany;

  String get requestDateLabel {
    if (requestDate == null) {
      return 'Date unavailable';
    }

    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${requestDate!.day.toString().padLeft(2, '0')} '
        '${months[requestDate!.month - 1]} ${requestDate!.year}';
  }

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory ApprovalRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final String roleValue = ((data['role'] ?? 'student') as String)
        .toLowerCase()
        .trim();
    final bool isApproved = data['isApproved'] == true;
    final String statusValue = ((data['status'] ?? '') as String).trim();

    return ApprovalRequest(
      id: doc.id,
      name: (data['name'] ?? data['fullName'] ?? 'Unknown User') as String,
      email: (data['email'] ?? '') as String,
      role: ApprovalRole.fromFirestore(roleValue),
      department: (data['department'] ?? 'Unassigned') as String,
      requestType: _buildRequestType(roleValue),
      requestDate: _readDateTime(data['createdAt'] ?? data['requestDate']),
      status: ApprovalStatus.fromFirestore(
        isApproved: isApproved,
        status: statusValue,
      ),
      notes: (data['notes'] ?? data['remarks'] ?? 'No notes added yet.')
          as String,
      profileSummary:
          (data['profileSummary'] ??
                  data['bio'] ??
                  data['about'] ??
                  'Profile summary not available.')
              as String,
      assignedFaculty:
          (data['assignedFaculty'] ?? data['facultyName']) as String?,
      assignedCompany:
          (data['assignedCompany'] ?? data['companyName'] ?? data['company'])
              as String?,
    );
  }

  static String _buildRequestType(String role) {
    switch (role) {
      case 'faculty':
        return 'Faculty account approval';
      case 'mentor':
        return 'Mentor verification request';
      default:
        return 'Student registration approval';
    }
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

enum ApprovalRole {
  student(label: 'Student', color: AppColors.primary),
  faculty(label: 'Faculty', color: AppColors.aquamarine),
  mentor(label: 'Mentor', color: AppColors.tangerineDream),
  other(label: 'Other', color: AppColors.jasmine);

  const ApprovalRole({required this.label, required this.color});

  final String label;
  final Color color;

  factory ApprovalRole.fromFirestore(String value) {
    switch (value) {
      case 'student':
        return ApprovalRole.student;
      case 'faculty':
        return ApprovalRole.faculty;
      case 'mentor':
        return ApprovalRole.mentor;
      default:
        return ApprovalRole.other;
    }
  }
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

  factory ApprovalStatus.fromFirestore({
    required bool isApproved,
    required String status,
  }) {
    final String normalized = status.toLowerCase();
    if (normalized == 'rejected') {
      return ApprovalStatus.rejected;
    }
    if (normalized == 'approved' || isApproved) {
      return ApprovalStatus.approved;
    }
    return ApprovalStatus.pending;
  }
}
