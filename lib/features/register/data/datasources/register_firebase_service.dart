import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/register_model.dart';

class RegisterFirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RegisterFirebaseService(this._auth, this._firestore);

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? previousInjuries,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final model = RegisterModel(
      uid: uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      previousInjuries: previousInjuries,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(model.toMap());
    return uid;
  }
}
