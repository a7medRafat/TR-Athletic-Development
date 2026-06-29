import 'package:flutter_test/flutter_test.dart';
import 'package:tr_atheletic_development/features/register/data/models/medical_models.dart';

void main() {
  group('MuscleInjuryEntry', () {
    test('round-trips through toMap/fromMap', () {
      final entry = MuscleInjuryEntry(
        muscleGroup: 'Hamstring',
        side: 'Left',
        date: DateTime(2023, 5, 15),
        grade: 'Grade 2',
        reinjury: true,
        daysLost: 10,
      );
      final parsed = MuscleInjuryEntry.fromMap(entry.toMap());
      expect(parsed.muscleGroup, 'Hamstring');
      expect(parsed.side, 'Left');
      expect(parsed.date, DateTime(2023, 5, 15));
      expect(parsed.grade, 'Grade 2');
      expect(parsed.reinjury, isTrue);
      expect(parsed.daysLost, 10);
    });

    test('fromMap defaults missing optional fields', () {
      final parsed = MuscleInjuryEntry.fromMap({'muscleGroup': 'Calf'});
      expect(parsed.muscleGroup, 'Calf');
      expect(parsed.side, isNull);
      expect(parsed.date, isNull);
      expect(parsed.grade, isNull);
      expect(parsed.reinjury, isFalse);
      expect(parsed.daysLost, isNull);
    });
  });

  group('JointInjuryEntry', () {
    test('round-trips through toMap/fromMap', () {
      final entry = JointInjuryEntry(
        injuryType: 'ACL',
        side: 'Right',
        date: DateTime(2022, 3, 20),
        surgeryRequired: true,
        reinjury: false,
      );
      final parsed = JointInjuryEntry.fromMap(entry.toMap());
      expect(parsed.injuryType, 'ACL');
      expect(parsed.side, 'Right');
      expect(parsed.date, DateTime(2022, 3, 20));
      expect(parsed.surgeryRequired, isTrue);
      expect(parsed.reinjury, isFalse);
    });
  });

  group('SurgeryEntry', () {
    test('round-trips through toMap/fromMap', () {
      final entry = SurgeryEntry(
        surgeryName: 'ACL Reconstruction',
        bodyArea: 'Left Knee',
        date: DateTime(2022, 4, 10),
        surgeon: 'Dr. Smith',
        returnToPlayDuration: '6 months',
        currentStatus: 'Ongoing Rehab',
      );
      final parsed = SurgeryEntry.fromMap(entry.toMap());
      expect(parsed.surgeryName, 'ACL Reconstruction');
      expect(parsed.bodyArea, 'Left Knee');
      expect(parsed.date, DateTime(2022, 4, 10));
      expect(parsed.surgeon, 'Dr. Smith');
      expect(parsed.returnToPlayDuration, '6 months');
      expect(parsed.currentStatus, 'Ongoing Rehab');
    });
  });

  group('MedicalHistory', () {
    test('round-trips full nested structure through toMap/fromMap', () {
      final history = MedicalHistory(
        muscleInjuries: [MuscleInjuryEntry(muscleGroup: 'Quadriceps', grade: 'Grade 1')],
        jointInjuries: [JointInjuryEntry(injuryType: 'Meniscus')],
        surgeries: [SurgeryEntry(surgeryName: 'Knee scope')],
        currentPain: true,
        chronicInjury: false,
        medications: true,
      );
      final parsed = MedicalHistory.fromMap(history.toMap());
      expect(parsed.muscleInjuries, hasLength(1));
      expect(parsed.muscleInjuries.first.muscleGroup, 'Quadriceps');
      expect(parsed.jointInjuries, hasLength(1));
      expect(parsed.jointInjuries.first.injuryType, 'Meniscus');
      expect(parsed.surgeries, hasLength(1));
      expect(parsed.surgeries.first.surgeryName, 'Knee scope');
      expect(parsed.currentPain, isTrue);
      expect(parsed.chronicInjury, isFalse);
      expect(parsed.medications, isTrue);
    });

    test('fromMap on an empty map yields an empty, default history', () {
      final parsed = MedicalHistory.fromMap({});
      expect(parsed.hasData, isFalse);
      expect(parsed.muscleInjuries, isEmpty);
      expect(parsed.jointInjuries, isEmpty);
      expect(parsed.surgeries, isEmpty);
      expect(parsed.riskProfile, 'Low');
    });

    test('hasData is true when only a current-status flag is set', () {
      const history = MedicalHistory(currentPain: true);
      expect(history.hasData, isTrue);
    });

    group('riskProfile', () {
      test('High when any surgery is recorded', () {
        final history = MedicalHistory(surgeries: [SurgeryEntry(surgeryName: 'Any')]);
        expect(history.riskProfile, 'High');
      });

      test('High on a Grade 3 muscle injury', () {
        final history = MedicalHistory(
          muscleInjuries: [MuscleInjuryEntry(muscleGroup: 'Calf', grade: 'Grade 3')],
        );
        expect(history.riskProfile, 'High');
      });

      test('Moderate on a joint injury with no surgery/reinjury/ACL/PCL', () {
        final history = MedicalHistory(
          jointInjuries: [JointInjuryEntry(injuryType: 'Meniscus')],
        );
        expect(history.riskProfile, 'Moderate');
      });

      test('Low when nothing is recorded', () {
        expect(const MedicalHistory().riskProfile, 'Low');
      });
    });
  });
}
