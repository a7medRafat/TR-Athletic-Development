import 'package:cloud_firestore/cloud_firestore.dart';

class PostTrainingModel {
  final String? id;
  final String uid;
  final int rpe;
  final bool completedWorkout;
  final bool feltPain;
  final String? painLocation;
  final bool injury;
  final int fatigue;
  final String? notes;
  final DateTime createdAt;

  const PostTrainingModel({
    this.id,
    required this.uid,
    required this.rpe,
    required this.completedWorkout,
    required this.feltPain,
    this.painLocation,
    required this.injury,
    required this.fatigue,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'rpe': rpe,
        'completedWorkout': completedWorkout,
        'feltPain': feltPain,
        'painLocation': painLocation,
        'injury': injury,
        'fatigue': fatigue,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PostTrainingModel.fromMap(Map<String, dynamic> map, String id) =>
      PostTrainingModel(
        id: id,
        uid: map['uid'] as String,
        rpe: (map['rpe'] as num).toInt(),
        completedWorkout: map['completedWorkout'] as bool,
        feltPain: map['feltPain'] as bool,
        painLocation: map['painLocation'] as String?,
        injury: map['injury'] as bool,
        fatigue: (map['fatigue'] as num).toInt(),
        notes: map['notes'] as String?,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
