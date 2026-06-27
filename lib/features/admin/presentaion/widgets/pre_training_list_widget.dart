import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';
import 'readiness_banner_widget.dart';
import 'session_card_widget.dart';

class PreTrainingListWidget extends StatelessWidget {
  final List<PreTrainingModel> sessions;
  final String Function(DateTime) fmt;

  const PreTrainingListWidget({
    super.key,
    required this.sessions,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return AppEmptyState(message: AppStrings.noHistory);
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: sessions.length,
      itemBuilder: (_, i) => PreCardWidget(session: sessions[i], fmt: fmt),
    );
  }
}

class PreCardWidget extends StatelessWidget {
  final PreTrainingModel session;
  final String Function(DateTime) fmt;

  const PreCardWidget({super.key, required this.session, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final readinessColor = _scale(s.readinessToTrain, 10, higher: true);
    return SessionCardWidget(
      date: fmt(s.createdAt),
      accentColor: AppColors.primary,
      readinessBanner: ReadinessBannerWidget(
        score: s.readinessToTrain,
        color: readinessColor,
      ),
      rows: [
        SessionRowData(
          icon: Icons.bedtime_rounded,
          label: AppStrings.sleep,
          value:
              '${s.hoursOfSleep.toStringAsFixed(s.hoursOfSleep == s.hoursOfSleep.roundToDouble() ? 0 : 1)} hrs',
          extra: AppStrings.sleepQualityDisplay(s.sleepQuality),
          valueColor: _scale(s.sleepQuality, 5, higher: true),
        ),
        SessionRowData(
          icon: Icons.battery_alert_rounded,
          label: AppStrings.fatigue,
          value: '${s.fatigueLevel}/10',
          valueColor: _scale(s.fatigueLevel, 10, higher: false),
        ),
        SessionRowData(
          icon: Icons.fitness_center_rounded,
          label: AppStrings.muscleSorenessShort,
          value: '${s.muscleSoreness}/10',
          valueColor: _scale(s.muscleSoreness, 10, higher: false),
        ),
        SessionRowData(
          icon: Icons.sentiment_satisfied_alt_rounded,
          label: AppStrings.mood,
          value: '${s.mood}/5',
          valueColor: _scale(s.mood, 5, higher: true),
        ),
        SessionRowData(
          icon: Icons.psychology_rounded,
          label: AppStrings.stress,
          value: '${s.stressLevel}/10',
          valueColor: _scale(s.stressLevel, 10, higher: false),
        ),
        SessionRowData(
          icon: Icons.bolt_rounded,
          label: AppStrings.energy,
          value: '${s.energyLevel}/10',
          valueColor: _scale(s.energyLevel, 10, higher: true),
        ),
        if (s.hasPainOrInjury)
          SessionRowData(
            icon: Icons.healing_rounded,
            label: AppStrings.painInjury,
            value: s.painLocation ?? AppStrings.yes,
            valueColor: AppColors.error,
          ),
      ],
    );
  }
}

Color _scale(int value, int max, {required bool higher}) {
  final ratio = value / max;
  if (higher) {
    if (ratio >= 0.7) return AppColors.success;
    if (ratio >= 0.4) return AppColors.warning;
    return AppColors.error;
  } else {
    if (ratio >= 0.7) return AppColors.error;
    if (ratio >= 0.4) return AppColors.warning;
    return AppColors.success;
  }
}
