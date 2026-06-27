class MuscleInjuryEntry {
  final String muscleGroup;
  String? side;
  DateTime? date;
  String? grade;
  bool reinjury;
  int? daysLost;

  MuscleInjuryEntry({
    required this.muscleGroup,
    this.side,
    this.date,
    this.grade,
    this.reinjury = false,
    this.daysLost,
  });

  Map<String, dynamic> toMap() => {
        'muscleGroup': muscleGroup,
        if (side != null) 'side': side,
        if (date != null) 'date': date!.toIso8601String().split('T').first,
        if (grade != null) 'grade': grade,
        'reinjury': reinjury,
        if (daysLost != null) 'daysLost': daysLost,
      };
}

class JointInjuryEntry {
  final String injuryType;
  String? side;
  DateTime? date;
  bool surgeryRequired;
  bool reinjury;

  JointInjuryEntry({
    required this.injuryType,
    this.side,
    this.date,
    this.surgeryRequired = false,
    this.reinjury = false,
  });

  Map<String, dynamic> toMap() => {
        'injuryType': injuryType,
        if (side != null) 'side': side,
        if (date != null) 'date': date!.toIso8601String().split('T').first,
        'surgeryRequired': surgeryRequired,
        'reinjury': reinjury,
      };
}

class SurgeryEntry {
  String surgeryName;
  String? bodyArea;
  DateTime? date;
  String? surgeon;
  String? returnToPlayDuration;
  String? currentStatus;

  SurgeryEntry({
    this.surgeryName = '',
    this.bodyArea,
    this.date,
    this.surgeon,
    this.returnToPlayDuration,
    this.currentStatus,
  });

  Map<String, dynamic> toMap() => {
        'surgeryName': surgeryName,
        if (bodyArea != null) 'bodyArea': bodyArea,
        if (date != null) 'date': date!.toIso8601String().split('T').first,
        if (surgeon != null) 'surgeon': surgeon,
        if (returnToPlayDuration != null)
          'returnToPlayDuration': returnToPlayDuration,
        if (currentStatus != null) 'currentStatus': currentStatus,
      };
}

class MedicalHistory {
  final List<MuscleInjuryEntry> muscleInjuries;
  final List<JointInjuryEntry> jointInjuries;
  final List<SurgeryEntry> surgeries;
  final bool currentPain;
  final bool chronicInjury;
  final bool medications;

  const MedicalHistory({
    this.muscleInjuries = const [],
    this.jointInjuries = const [],
    this.surgeries = const [],
    this.currentPain = false,
    this.chronicInjury = false,
    this.medications = false,
  });

  String get riskProfile {
    final hasHighRisk = surgeries.isNotEmpty ||
        muscleInjuries.any((m) => m.grade == 'Grade 3' || m.reinjury) ||
        jointInjuries.any(
          (j) =>
              j.surgeryRequired ||
              j.reinjury ||
              j.injuryType == 'ACL' ||
              j.injuryType == 'PCL',
        );
    if (hasHighRisk) return 'High';

    final hasModerateRisk =
        muscleInjuries.any((m) => m.grade == 'Grade 2') ||
            jointInjuries.isNotEmpty ||
            chronicInjury ||
            currentPain;
    if (hasModerateRisk) return 'Moderate';

    return 'Low';
  }

  Map<String, dynamic> toMap() => {
        'muscleInjuries': muscleInjuries.map((e) => e.toMap()).toList(),
        'jointInjuries': jointInjuries.map((e) => e.toMap()).toList(),
        'surgeries': surgeries.map((e) => e.toMap()).toList(),
        'currentMedicalStatus': {
          'currentPain': currentPain,
          'chronicInjury': chronicInjury,
          'medications': medications,
        },
        'injuryRiskProfile': riskProfile,
      };
}
