import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_training_model.dart';

class PostTrainingFirebaseService {
  final FirebaseFirestore _firestore;

  static const String _collection = 'post_training';

  PostTrainingFirebaseService(this._firestore);

  Future<String> submit(PostTrainingModel model) async {
    final docRef = await _firestore.collection(_collection).add(model.toMap());
    return docRef.id;
  }

  Future<List<PostTrainingModel>> fetchByUid(String uid) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostTrainingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
