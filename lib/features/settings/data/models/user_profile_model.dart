class UserProfileModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String status;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.role = 'user',
    this.status = 'approved',
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) => UserProfileModel(
        uid: map['uid'] as String,
        email: (map['email'] as String?) ?? '',
        fullName: (map['fullName'] as String?) ?? '',
        phoneNumber: (map['phoneNumber'] as String?) ?? '',
        role: (map['role'] as String?) ?? 'user',
        status: (map['status'] as String?) ?? 'approved',
      );

  bool get isAdmin => role == 'admin';
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isDisabled => status == 'disabled';
}
