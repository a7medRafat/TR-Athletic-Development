import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

// ── Risk classification ────────────────────────────────────────────────────────

enum AcwrStatus { veryLow, optimal, elevated, highRisk }

extension AcwrStatusX on AcwrStatus {
  Color get color {
    switch (this) {
      case AcwrStatus.veryLow:
        return const Color(0xFF3B82F6); // blue
      case AcwrStatus.optimal:
        return AppColors.success;
      case AcwrStatus.elevated:
        return AppColors.warning;
      case AcwrStatus.highRisk:
        return AppColors.error;
    }
  }

  String get label {
    switch (this) {
      case AcwrStatus.veryLow:
        return 'Detraining';
      case AcwrStatus.optimal:
        return 'Optimal';
      case AcwrStatus.elevated:
        return 'Monitor';
      case AcwrStatus.highRisk:
        return 'High Risk';
    }
  }

  String get description {
    switch (this) {
      case AcwrStatus.veryLow:
        return 'Training load is significantly below normal.';
      case AcwrStatus.optimal:
        return 'Current workload is balanced. Safe training zone.';
      case AcwrStatus.elevated:
        return 'Higher than normal workload. Consider reducing intensity.';
      case AcwrStatus.highRisk:
        return 'Training load increased significantly. Very high injury risk.';
    }
  }

  IconData get icon {
    switch (this) {
      case AcwrStatus.veryLow:
        return Icons.trending_down_rounded;
      case AcwrStatus.optimal:
        return Icons.check_circle_rounded;
      case AcwrStatus.elevated:
        return Icons.warning_amber_rounded;
      case AcwrStatus.highRisk:
        return Icons.dangerous_rounded;
    }
  }
}

// ── Domain models ──────────────────────────────────────────────────────────────

class DailyLoad {
  final DateTime date;
  final double load;

  const DailyLoad({required this.date, required this.load});
}

class WorkloadMetrics {
  /// Sum of training loads over the last 7 days.
  final double acuteLoad;

  /// Sum of training loads over the last 28 days divided by 4.
  final double chronicLoad;

  /// Acute / Chronic ratio.
  final double acwr;

  final AcwrStatus status;

  /// Daily loads for the last 28 days, oldest → newest.
  final List<DailyLoad> dailyLoads;

  /// Rolling acute load per day for last 28 days, oldest → newest.
  final List<double> acuteHistory;

  /// Rolling chronic load per day for last 28 days, oldest → newest.
  final List<double> chronicHistory;

  /// Rolling ACWR per day for last 28 days, oldest → newest.
  final List<double> acwrHistory;

  /// True only when the earliest session with load is ≥ 7 days before today.
  /// Until then acute load and ACWR are not meaningful.
  final bool isAcuteReady;

  /// True only when the earliest session with load is ≥ 28 days before today.
  /// Chronic load is the 4-week rolling average — requires a full 4-week window.
  final bool isChronicReady;

  // Summary stats
  final double peakAcute;
  final double peakChronic;
  final double peakAcwr;
  final double avgDailyLoad;
  final int totalSessionsWithLoad;

  const WorkloadMetrics({
    required this.acuteLoad,
    required this.chronicLoad,
    required this.acwr,
    required this.status,
    required this.dailyLoads,
    required this.acuteHistory,
    required this.chronicHistory,
    required this.acwrHistory,
    required this.isAcuteReady,
    required this.isChronicReady,
    required this.peakAcute,
    required this.peakChronic,
    required this.peakAcwr,
    required this.avgDailyLoad,
    required this.totalSessionsWithLoad,
  });

  bool get hasData => totalSessionsWithLoad > 0;

  static WorkloadMetrics empty() => const WorkloadMetrics(
        acuteLoad: 0,
        chronicLoad: 0,
        acwr: 0,
        status: AcwrStatus.veryLow,
        dailyLoads: [],
        acuteHistory: [],
        chronicHistory: [],
        acwrHistory: [],
        isAcuteReady: false,
        isChronicReady: false,
        peakAcute: 0,
        peakChronic: 0,
        peakAcwr: 0,
        avgDailyLoad: 0,
        totalSessionsWithLoad: 0,
      );
}
