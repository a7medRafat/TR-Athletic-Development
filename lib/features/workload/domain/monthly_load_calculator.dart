import '../../post_training/data/models/post_training_model.dart';
import '../data/models/workload_models.dart';
import 'workload_calculator.dart';

/// Groups training load by calendar month/day for month-by-month historical
/// review. Distinct from [WorkloadCalculator], which only tracks a rolling
/// 7-day/28-day window relative to today.
class MonthlyLoadCalculator {
  final TrainingLoadCalculator _loadCalc;

  MonthlyLoadCalculator({TrainingLoadCalculator? calculator})
      : _loadCalc = calculator ?? const RpeLoadCalculator();

  /// Calendar months (1st-of-month, oldest → newest) that contain at least
  /// one session with load, plus [referenceDate]'s month so "this month" is
  /// always selectable even before the first session is logged.
  List<DateTime> availableMonths(
    List<PostTrainingModel> sessions,
    DateTime referenceDate,
  ) {
    final months = <DateTime>{
      DateTime(referenceDate.year, referenceDate.month),
    };
    for (final s in sessions) {
      if (_loadCalc.calculate(s) > 0) {
        months.add(DateTime(s.createdAt.year, s.createdAt.month));
      }
    }
    return months.toList()..sort();
  }

  /// One [DailyLoad] per calendar day of [month] (1st → last day), oldest →
  /// newest. Only [month]'s year/month are used; day/time are ignored.
  List<DailyLoad> dailyLoadsForMonth(
    List<PostTrainingModel> sessions,
    DateTime month,
  ) {
    final dailyMap = <DateTime, double>{};
    for (final s in sessions) {
      if (s.createdAt.year != month.year || s.createdAt.month != month.month) {
        continue;
      }
      final load = _loadCalc.calculate(s);
      if (load > 0) {
        final d = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
        dailyMap[d] = (dailyMap[d] ?? 0) + load;
      }
    }

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final d = DateTime(month.year, month.month, i + 1);
      return DailyLoad(date: d, load: dailyMap[d] ?? 0);
    });
  }

  /// Splits a full month of [DailyLoad]s into 4 fixed weeks: days 1–7, 8–14,
  /// 15–21 and 22–end. Assumes [monthDays] came from [dailyLoadsForMonth]
  /// (always 28–31 entries), so week 4 absorbs the trailing 7–10 days.
  List<List<DailyLoad>> splitIntoWeeks(List<DailyLoad> monthDays) {
    return [
      monthDays.sublist(0, 7),
      monthDays.sublist(7, 14),
      monthDays.sublist(14, 21),
      monthDays.sublist(21),
    ];
  }
}
