import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../features/pre_training/data/models/pre_training_model.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../models/admin_user_model.dart';

class AdminFirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminFirebaseService(this._auth, this._firestore);

  String? get currentUid => _auth.currentUser?.uid;

  Stream<List<AdminUserModel>> streamUsers({String? statusFilter}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'user');
    if (statusFilter != null && statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }
    return query.snapshots().map(
          (snap) => snap.docs
              .map((d) => AdminUserModel.fromMap({...d.data(), 'uid': d.id}))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': currentUid,
      'rejectionReason': null,
    });
  }

  Future<void> rejectUser(String uid, {String? reason}) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': currentUid,
      'rejectionReason': reason,
    });
  }

  Future<void> setUserStatus(String uid, String status) async {
    final data = <String, dynamic>{'status': status};
    if (status == 'disabled') {
      data['disabledAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<AdminUserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AdminUserModel.fromMap({...doc.data()!, 'uid': doc.id});
  }

  Future<List<PreTrainingModel>> getPreTrainingSessions(String uid) async {
    final snap = await _firestore
        .collection('pre_training')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PreTrainingModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<PostTrainingModel>> getPostTrainingSessions(String uid) async {
    final snap = await _firestore
        .collection('post_training')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PostTrainingModel.fromMap(d.data(), d.id))
        .toList();
  }
}
