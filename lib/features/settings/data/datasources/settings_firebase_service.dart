import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';

class SettingsFirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SettingsFirebaseService(this._auth, this._firestore);

  String? get currentUserEmail => _auth.currentUser?.email;

  Future<UserProfileModel?> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfileModel.fromMap(doc.data()!);
  }

  Future<void> signOut() => _auth.signOut();
}
