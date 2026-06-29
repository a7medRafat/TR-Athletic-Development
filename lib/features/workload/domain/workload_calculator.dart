import '../../post_training/data/models/post_training_model.dart';
import '../data/models/workload_models.dart';

// ── Abstract load calculator (extensible) ─────────────────────────────────────

abstract class TrainingLoadCalculator {
  /// Returns the training load (AU) for a single session.
  double calculate(PostTrainingModel session);
}

/// RPE × Duration (minutes). Returns 0 if duration is missing.
class RpeLoadCalculator implements TrainingLoadCalculator {
  const RpeLoadCalculator();

  @override
  double calculate(PostTrainingModel session) {
    if (session.trainingDuration == null || session.trainingDuration! <= 0) {
      return 0;
    }
    return session.rpe * session.trainingDuration!;
  }
}

// ── Core workload calculator ───────────────────────────────────────────────────

class WorkloadCalculator {
  final TrainingLoadCalculator _loadCalc;

  WorkloadCalculator({TrainingLoadCalculator? calculator})
      : _loadCalc = calculator ?? const RpeLoadCalculator();

  /// Computes full [WorkloadMetrics] from [sessions] relative to [referenceDate]
  /// (typically today). Uses rolling 7-day acute and 28-day chronic windows.
  WorkloadMetrics compute(
    List<PostTrainingModel> sessions,
    DateTime referenceDate,
  ) {
    final today = _stripTime(referenceDate);

    // Build a map: date → total daily load (sum across all sessions that day)
    final Map<DateTime, double> dailyMap = {};
    int sessionsWithLoad = 0;
    for (final s in sessions) {
      final load = _loadCalc.calculate(s);
      if (load > 0) {
        final d = _stripTime(s.createdAt);
        dailyMap[d] = (dailyMap[d] ?? 0) + load;
        sessionsWithLoad++;
      }
    }

    if (sessionsWithLoad == 0) return WorkloadMetrics.empty();

    // Readiness gates: acute requires 7-day window, chronic requires 28-day window
    final earliestDate = dailyMap.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final daysSinceFirst = today.difference(earliestDate).inDays;
    final isAcuteReady = daysSinceFirst >= 7;
    final isChronicReady = daysSinceFirst >= 28;

    // Build ordered list of last 28 days (oldest → newest)
    final List<DailyLoad> last28 = List.generate(
      28,
      (i) {
        final d = today.subtract(Duration(days: 27 - i));
        return DailyLoad(date: d, load: dailyMap[d] ?? 0);
      },
    );

    // Rolling histories — one value per day in last28
    final acuteHistory = <double>[];
    final chronicHistory = <double>[];
    final acwrHistory = <double>[];

    for (int i = 0; i < 28; i++) {
      final dayDate = last28[i].date;

      // Acute = sum of loads in [dayDate-6 .. dayDate]
      double acute = 0;
      for (int j = 0; j < 7; j++) {
        acute += dailyMap[dayDate.subtract(Duration(days: j))] ?? 0;
      }

      // Chronic = sum of loads in [dayDate-27 .. dayDate] / 4
      double sum28 = 0;
      for (int j = 0; j < 28; j++) {
        sum28 += dailyMap[dayDate.subtract(Duration(days: j))] ?? 0;
      }
      final chronic = sum28 / 4.0;
      final acwr = chronic > 0 ? acute / chronic : 0.0;

      acuteHistory.add(acute);
      chronicHistory.add(chronic);
      acwrHistory.add(acwr);
    }

    final acuteLoad = acuteHistory.last;
    final chronicLoad = chronicHistory.last;
    final currentAcwr = acwrHistory.last;

    // Summary stats
    final peakAcute = acuteHistory.reduce((a, b) => a > b ? a : b);
    final peakChronic = chronicHistory.reduce((a, b) => a > b ? a : b);
    final peakAcwr = acwrHistory.reduce((a, b) => a > b ? a : b);
    final nonZeroLoads = dailyMap.values.where((v) => v > 0).toList();
    final avgDailyLoad = nonZeroLoads.isEmpty
        ? 0.0
        : nonZeroLoads.reduce((a, b) => a + b) / nonZeroLoads.length;

    return WorkloadMetrics(
      acuteLoad: acuteLoad,
      chronicLoad: chronicLoad,
      acwr: currentAcwr,
      status: _classify(isAcuteReady && isChronicReady ? currentAcwr : 0),
      acuteHistory: acuteHistory,
      chronicHistory: chronicHistory,
      acwrHistory: acwrHistory,
      isAcuteReady: isAcuteReady,
      isChronicReady: isChronicReady,
      peakAcute: peakAcute,
      peakChronic: peakChronic,
      peakAcwr: peakAcwr,
      avgDailyLoad: avgDailyLoad,
      totalSessionsWithLoad: sessionsWithLoad,
    );
  }

  AcwrStatus _classify(double acwr) {
    if (acwr <= 0 || acwr < 0.80) return AcwrStatus.veryLow;
    if (acwr <= 1.30) return AcwrStatus.optimal;
    if (acwr <= 1.50) return AcwrStatus.elevated;
    return AcwrStatus.highRisk;
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
