import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterModel {
  final String? id;
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? previousInjuries;
  final String role;
  final String status;
  final DateTime createdAt;

  const RegisterModel({
    this.id,
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.previousInjuries,
    this.role = 'user',
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (gender != null) 'gender': gender,
        if (previousInjuries != null && previousInjuries!.isNotEmpty)
          'previousInjuries': previousInjuries,
        'role': role,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory RegisterModel.fromMap(Map<String, dynamic> map, String id) =>
      RegisterModel(
        id: id,
        uid: map['uid'] as String,
        email: map['email'] as String,
        fullName: map['fullName'] as String,
        phoneNumber: map['phoneNumber'] as String,
        age: (map['age'] as num?)?.toInt(),
        weight: (map['weight'] as num?)?.toDouble(),
        height: (map['height'] as num?)?.toDouble(),
        gender: map['gender'] as String?,
        role: (map['role'] as String?) ?? 'user',
        status: (map['status'] as String?) ?? 'pending',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
