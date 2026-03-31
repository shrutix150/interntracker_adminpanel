import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    required this.industry,
    this.contactEmail,
    this.contactPerson,
    this.phoneNumber,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String industry;
  final String? contactEmail;
  final String? contactPerson;
  final String? phoneNumber;
  final bool isActive;
  final DateTime? createdAt;

  factory CompanyModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return CompanyModel(
      id: doc.id,
      name: (data['name'] ?? 'Unnamed Company') as String,
      industry: (data['industry'] ?? 'Unknown Industry') as String,
      contactEmail: data['contactEmail'] as String?,
      contactPerson: data['contactPerson'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      isActive: data['isActive'] != false,
      createdAt: _readDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'industry': industry,
      'contactEmail': contactEmail,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
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
