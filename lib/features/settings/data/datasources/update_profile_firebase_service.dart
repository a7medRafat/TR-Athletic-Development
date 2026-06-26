import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileFirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UpdateProfileFirebaseService(this._auth, this._firestore);

  Future<void> update({
    required String fullName,
    required String phoneNumber,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    });
  }
}
