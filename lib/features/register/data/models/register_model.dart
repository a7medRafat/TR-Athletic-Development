import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterModel {
  final String? id;
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final DateTime createdAt;

  const RegisterModel({
    this.id,
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory RegisterModel.fromMap(Map<String, dynamic> map, String id) =>
      RegisterModel(
        id: id,
        uid: map['uid'] as String,
        email: map['email'] as String,
        fullName: map['fullName'] as String,
        phoneNumber: map['phoneNumber'] as String,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
