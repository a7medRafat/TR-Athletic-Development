import 'package:cloud_firestore/cloud_firestore.dart';

class PreTrainingModel {
  final String? id;
  final String uid;
  final int sleepQuality;
  final double hoursOfSleep;
  final int fatigueLevel;
  final int muscleSoreness;
  final int mood;
  final int stressLevel;
  final int energyLevel;
  final bool hasPainOrInjury;
  final String? painLocation;
  final int readinessToTrain;
  final DateTime createdAt;

  const PreTrainingModel({
    this.id,
    required this.uid,
    required this.sleepQuality,
    required this.hoursOfSleep,
    required this.fatigueLevel,
    required this.muscleSoreness,
    required this.mood,
    required this.stressLevel,
    required this.energyLevel,
    required this.hasPainOrInjury,
    this.painLocation,
    required this.readinessToTrain,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'sleepQuality': sleepQuality,
        'hoursOfSleep': hoursOfSleep,
        'fatigueLevel': fatigueLevel,
        'muscleSoreness': muscleSoreness,
        'mood': mood,
        'stressLevel': stressLevel,
        'energyLevel': energyLevel,
        'hasPainOrInjury': hasPainOrInjury,
        'painLocation': painLocation,
        'readinessToTrain': readinessToTrain,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PreTrainingModel.fromMap(Map<String, dynamic> map, String id) =>
      PreTrainingModel(
        id: id,
        uid: map['uid'] as String,
        sleepQuality: (map['sleepQuality'] as num).toInt(),
        hoursOfSleep: (map['hoursOfSleep'] as num).toDouble(),
        fatigueLevel: (map['fatigueLevel'] as num).toInt(),
        muscleSoreness: (map['muscleSoreness'] as num).toInt(),
        mood: (map['mood'] as num).toInt(),
        stressLevel: (map['stressLevel'] as num).toInt(),
        energyLevel: (map['energyLevel'] as num).toInt(),
        hasPainOrInjury: map['hasPainOrInjury'] as bool,
        painLocation: map['painLocation'] as String?,
        readinessToTrain: (map['readinessToTrain'] as num).toInt(),
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
