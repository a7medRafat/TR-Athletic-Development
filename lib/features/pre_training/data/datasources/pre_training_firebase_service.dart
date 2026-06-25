import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pre_training_model.dart';

class PreTrainingFirebaseService {
  final FirebaseFirestore _firestore;

  static const String _collection = 'pre_training';

  PreTrainingFirebaseService(this._firestore);

  Future<String> submit(PreTrainingModel model) async {
    final docRef = await _firestore.collection(_collection).add(model.toMap());
    return docRef.id;
  }

  Future<List<PreTrainingModel>> fetchByUid(String uid) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PreTrainingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
