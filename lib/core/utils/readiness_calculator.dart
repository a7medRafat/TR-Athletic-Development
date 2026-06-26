import '../../features/pre_training/data/models/pre_training_model.dart';

class ReadinessCalculator {
  // Threshold on 1-10 scale
  static const int readyThreshold = 7;

  /// Returns a readiness score on a 1-10 scale.
  ///
  /// Internal scoring (0-100):
  ///   Sleep hours    20 pts  (8h or more = full points)
  ///   Sleep quality   5 pts  (scale 1-5)
  ///   Energy level   20 pts  (scale 1-10, higher = better)
  ///   Fatigue level  20 pts  (scale 1-10, lower = better)
  ///   Muscle soren.  15 pts  (scale 1-10, lower = better)
  ///   Mood           10 pts  (scale 1-5,  higher = better)
  ///   Stress level   10 pts  (scale 1-10, lower = better)
  ///   Pain penalty   -10 pts (deducted if hasPainOrInjury)
  static int calculate(PreTrainingModel s) {
    double score = 0;

    // Sleep hours (0-20): cap at 8h
    score += (s.hoursOfSleep.clamp(0, 8) / 8) * 20;

    // Sleep quality (0-5): scale 1-10
    score += ((s.sleepQuality - 1) / 9) * 5;

    // Energy level (0-20): scale 1-10
    score += ((s.energyLevel - 1) / 9) * 20;

    // Fatigue level (0-20): inverted scale 1-10
    score += ((10 - s.fatigueLevel) / 9) * 20;

    // Muscle soreness (0-15): inverted scale 1-10
    score += ((10 - s.muscleSoreness) / 9) * 15;

    // Mood (0-10): scale 1-5
    score += ((s.mood - 1) / 4) * 10;

    // Stress level (0-10): inverted scale 1-10
    score += ((10 - s.stressLevel) / 9) * 10;

    // Pain / injury penalty
    if (s.hasPainOrInjury) score -= 10;

    // Convert 0-100 to 1-10
    return (score / 10).round().clamp(1, 10);
  }

  static bool isReady(int score) => score >= readyThreshold;

  static bool isReadyFromSession(PreTrainingModel s) =>
      isReady(calculate(s));
}
