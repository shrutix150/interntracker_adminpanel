import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    required this.status,
    required this.internshipStatus,
    this.department,
    this.phoneNumber,
    this.companyName,
    this.assignedFaculty,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool isApproved;
  final String status;
  final String internshipStatus;
  final String? department;
  final String? phoneNumber;
  final String? companyName;
  final String? assignedFaculty;
  final DateTime? createdAt;

  factory StudentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return StudentModel(
      id: doc.id,
      name: (data['name'] ?? data['fullName'] ?? 'Unnamed Student') as String,
      email: (data['email'] ?? '') as String,
      role: ((data['role'] ?? 'student') as String).toLowerCase(),
      isApproved: data['isApproved'] == true,
      status: (data['status'] ?? 'Pending') as String,
      internshipStatus: (data['internshipStatus'] ?? 'Unknown') as String,
      department: data['department'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      companyName: (data['companyName'] ?? data['company']) as String?,
      assignedFaculty:
          (data['assignedFaculty'] ?? data['facultyName']) as String?,
      createdAt: _readDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,
      'isApproved': isApproved,
      'status': status,
      'internshipStatus': internshipStatus,
      'department': department,
      'phoneNumber': phoneNumber,
      'companyName': companyName,
      'assignedFaculty': assignedFaculty,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
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
