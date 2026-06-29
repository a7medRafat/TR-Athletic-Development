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

  factory MuscleInjuryEntry.fromMap(Map<String, dynamic> map) =>
      MuscleInjuryEntry(
        muscleGroup: map['muscleGroup'] as String? ?? '',
        side: map['side'] as String?,
        date: map['date'] != null
            ? DateTime.tryParse(map['date'] as String)
            : null,
        grade: map['grade'] as String?,
        reinjury: map['reinjury'] as bool? ?? false,
        daysLost: (map['daysLost'] as num?)?.toInt(),
      );

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

  factory JointInjuryEntry.fromMap(Map<String, dynamic> map) =>
      JointInjuryEntry(
        injuryType: map['injuryType'] as String? ?? '',
        side: map['side'] as String?,
        date: map['date'] != null
            ? DateTime.tryParse(map['date'] as String)
            : null,
        surgeryRequired: map['surgeryRequired'] as bool? ?? false,
        reinjury: map['reinjury'] as bool? ?? false,
      );

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

  factory SurgeryEntry.fromMap(Map<String, dynamic> map) => SurgeryEntry(
        surgeryName: map['surgeryName'] as String? ?? '',
        bodyArea: map['bodyArea'] as String?,
        date: map['date'] != null
            ? DateTime.tryParse(map['date'] as String)
            : null,
        surgeon: map['surgeon'] as String?,
        returnToPlayDuration: map['returnToPlayDuration'] as String?,
        currentStatus: map['currentStatus'] as String?,
      );

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

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    final currentStatus =
        map['currentMedicalStatus'] as Map<String, dynamic>? ?? const {};
    return MedicalHistory(
      muscleInjuries: ((map['muscleInjuries'] as List?) ?? const [])
          .map((e) => MuscleInjuryEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      jointInjuries: ((map['jointInjuries'] as List?) ?? const [])
          .map((e) => JointInjuryEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      surgeries: ((map['surgeries'] as List?) ?? const [])
          .map((e) => SurgeryEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      currentPain: currentStatus['currentPain'] as bool? ?? false,
      chronicInjury: currentStatus['chronicInjury'] as bool? ?? false,
      medications: currentStatus['medications'] as bool? ?? false,
    );
  }

  bool get hasData =>
      muscleInjuries.isNotEmpty ||
      jointInjuries.isNotEmpty ||
      surgeries.isNotEmpty ||
      currentPain ||
      chronicInjury ||
      medications;

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
