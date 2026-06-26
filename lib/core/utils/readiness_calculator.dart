import '../../features/pre_training/data/models/pre_training_model.dart';

class ReadinessCalculator {
  // Threshold — score must be >= this to be considered Ready
  static const int readyThreshold = 90;

  /// Calculates a readiness score from 0 to 100.
  ///
  /// Scoring breakdown:
  ///   Sleep hours    20 pts   (8h or more = full points)
  ///   Sleep quality  10 pts   (scale 1-5)
  ///   Energy level   20 pts   (scale 1-10, higher = better)
  ///   Fatigue level  20 pts   (scale 1-10, lower = better)
  ///   Muscle soren.  10 pts   (scale 1-10, lower = better)
  ///   Mood           10 pts   (scale 1-5,  higher = better)
  ///   Stress level   10 pts   (scale 1-10, lower = better)
  ///   Pain penalty   -10 pts  (deducted if hasPainOrInjury)
  static int calculate(PreTrainingModel s) {
    double score = 0;

    // Sleep hours (0-20): cap at 8h
    score += (s.hoursOfSleep.clamp(0, 8) / 8) * 20;

    // Sleep quality (0-10): scale 1-5
    score += ((s.sleepQuality - 1) / 4) * 10;

    // Energy level (0-20): scale 1-10
    score += ((s.energyLevel - 1) / 9) * 20;

    // Fatigue level (0-20): inverted scale 1-10
    score += ((10 - s.fatigueLevel) / 9) * 20;

    // Muscle soreness (0-10): inverted scale 1-10
    score += ((10 - s.muscleSoreness) / 9) * 10;

    // Mood (0-10): scale 1-5
    score += ((s.mood - 1) / 4) * 10;

    // Stress level (0-10): inverted scale 1-10
    score += ((10 - s.stressLevel) / 9) * 10;

    // Pain / injury penalty
    if (s.hasPainOrInjury) score -= 10;

    return score.round().clamp(0, 100);
  }

  static bool isReady(int score) => score >= readyThreshold;

  static bool isReadyFromSession(PreTrainingModel s) =>
      isReady(calculate(s));
}
