class UserProfileModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) => UserProfileModel(
        uid: map['uid'] as String,
        email: (map['email'] as String?) ?? '',
        fullName: (map['fullName'] as String?) ?? '',
        phoneNumber: (map['phoneNumber'] as String?) ?? '',
      );
}
