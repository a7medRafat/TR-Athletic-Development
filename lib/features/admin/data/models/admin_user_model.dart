import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../register/data/models/medical_models.dart';

class AdminUserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime? disabledAt;
  final int? lastReadinessScore;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final MedicalHistory? medicalHistory;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.role = 'user',
    this.status = 'pending',
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.disabledAt,
    this.lastReadinessScore,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.medicalHistory,
  });

  bool get isAdmin => role == 'admin';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isDisabled => status == 'disabled';

  String get initials {
    if (fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  factory AdminUserModel.fromMap(Map<String, dynamic> map) {
    DateTime? _ts(dynamic v) =>
        v == null ? null : (v as Timestamp).toDate();
    return AdminUserModel(
      uid: map['uid'] as String,
      email: (map['email'] as String?) ?? '',
      fullName: (map['fullName'] as String?) ?? '',
      phoneNumber: (map['phoneNumber'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'user',
      status: (map['status'] as String?) ?? 'pending',
      createdAt: _ts(map['createdAt']) ?? DateTime.now(),
      approvedAt: _ts(map['approvedAt']),
      approvedBy: map['approvedBy'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      disabledAt: _ts(map['disabledAt']),
      lastReadinessScore: (map['lastReadinessScore'] as num?)?.toInt(),
      age: (map['age'] as num?)?.toInt(),
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      gender: map['gender'] as String?,
      medicalHistory: map['medicalHistory'] != null
          ? MedicalHistory.fromMap(map['medicalHistory'] as Map<String, dynamic>)
          : null,
    );
  }
}
