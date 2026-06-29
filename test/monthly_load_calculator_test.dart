import 'package:flutter_test/flutter_test.dart';
import 'package:tr_atheletic_development/features/post_training/data/models/post_training_model.dart';
import 'package:tr_atheletic_development/features/workload/domain/monthly_load_calculator.dart';

PostTrainingModel _session({
  required DateTime createdAt,
  int rpe = 5,
  double? trainingDuration = 60,
}) =>
    PostTrainingModel(
      uid: 'u1',
      rpe: rpe,
      completedWorkout: true,
      feltPain: false,
      injury: false,
      fatigue: 3,
      trainingDuration: trainingDuration,
      createdAt: createdAt,
    );

void main() {
  final calc = MonthlyLoadCalculator();

  group('availableMonths', () {
    test('always includes the reference month even with no sessions', () {
      final months = calc.availableMonths([], DateTime(2026, 6, 15));
      expect(months, [DateTime(2026, 6)]);
    });

    test('includes distinct months from sessions, sorted oldest to newest', () {
      final sessions = [
        _session(createdAt: DateTime(2026, 3, 10)),
        _session(createdAt: DateTime(2026, 1, 5)),
        _session(createdAt: DateTime(2026, 3, 20)), // same month as above
      ];
      final months = calc.availableMonths(sessions, DateTime(2026, 6, 15));
      expect(months, [
        DateTime(2026, 1),
        DateTime(2026, 3),
        DateTime(2026, 6), // reference month, even though no session in it
      ]);
    });

    test('excludes sessions with no load (missing/zero duration)', () {
      final sessions = [
        _session(createdAt: DateTime(2026, 2, 1), trainingDuration: null),
        _session(createdAt: DateTime(2026, 2, 2), trainingDuration: 0),
      ];
      final months = calc.availableMonths(sessions, DateTime(2026, 6, 15));
      expect(months, [DateTime(2026, 6)]);
    });
  });

  group('dailyLoadsForMonth', () {
    test('returns one entry per day of the month, oldest to newest', () {
      final days = calc.dailyLoadsForMonth([], DateTime(2026, 4, 1));
      expect(days.length, 30); // April
      expect(days.first.date, DateTime(2026, 4, 1));
      expect(days.last.date, DateTime(2026, 4, 30));
      expect(days.every((d) => d.load == 0), isTrue);
    });

    test('handles leap vs non-leap February', () {
      expect(calc.dailyLoadsForMonth([], DateTime(2024, 2, 1)).length, 29);
      expect(calc.dailyLoadsForMonth([], DateTime(2025, 2, 1)).length, 28);
    });

    test('sums multiple sessions on the same day', () {
      final sessions = [
        _session(createdAt: DateTime(2026, 5, 10, 8), rpe: 4, trainingDuration: 30),
        _session(createdAt: DateTime(2026, 5, 10, 18), rpe: 6, trainingDuration: 40),
      ];
      final days = calc.dailyLoadsForMonth(sessions, DateTime(2026, 5, 1));
      final day10 = days.firstWhere((d) => d.date.day == 10);
      expect(day10.load, 4 * 30 + 6 * 40);
    });

    test('ignores sessions from other months', () {
      final sessions = [_session(createdAt: DateTime(2026, 6, 1))];
      final days = calc.dailyLoadsForMonth(sessions, DateTime(2026, 5, 1));
      expect(days.every((d) => d.load == 0), isTrue);
    });
  });

  group('splitIntoWeeks', () {
    test('splits a 28-day month into four even 7-day weeks', () {
      final days = calc.dailyLoadsForMonth([], DateTime(2025, 2, 1)); // 28 days
      final weeks = calc.splitIntoWeeks(days);
      expect(weeks.length, 4);
      expect(weeks.map((w) => w.length), [7, 7, 7, 7]);
      expect(weeks[0].first.date.day, 1);
      expect(weeks[3].last.date.day, 28);
    });

    test('week 4 absorbs the trailing days for longer months', () {
      final days = calc.dailyLoadsForMonth([], DateTime(2026, 1, 1)); // 31 days
      final weeks = calc.splitIntoWeeks(days);
      expect(weeks.map((w) => w.length), [7, 7, 7, 10]);
      expect(weeks[3].first.date.day, 22);
      expect(weeks[3].last.date.day, 31);
    });
  });
}
