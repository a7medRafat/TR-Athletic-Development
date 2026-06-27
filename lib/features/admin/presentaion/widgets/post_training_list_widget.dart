import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import 'session_card_widget.dart';

class PostTrainingListWidget extends StatelessWidget {
  final List<PostTrainingModel> sessions;
  final String Function(DateTime) fmt;

  const PostTrainingListWidget({
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
      itemBuilder: (_, i) => PostCardWidget(session: sessions[i], fmt: fmt),
    );
  }
}

class PostCardWidget extends StatelessWidget {
  final PostTrainingModel session;
  final String Function(DateTime) fmt;

  const PostCardWidget({super.key, required this.session, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return SessionCardWidget(
      date: fmt(s.createdAt),
      accentColor: AppColors.accent,
      rows: [
        SessionRowData(
          icon: Icons.speed_rounded,
          label: AppStrings.rpe,
          value: '${s.rpe}/9',
          valueColor: _scale(s.rpe, 9, higher: false),
          bold: true,
        ),
        if (s.trainingDuration != null)
          SessionRowData(
            icon: Icons.timer_rounded,
            label: AppStrings.trainingDuration,
            value: '${s.trainingDuration!.round()} min',
            extra: 'Load: ${(s.rpe * s.trainingDuration!).toStringAsFixed(0)}',
            valueColor: AppColors.primary,
          ),
        SessionRowData(
          icon: Icons.battery_alert_rounded,
          label: AppStrings.fatigue,
          value: '${s.fatigue}/5',
          valueColor: _scale(s.fatigue, 5, higher: false),
        ),
        SessionRowData(
          icon: s.completedWorkout
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          label: AppStrings.completedWorkoutShort,
          value: s.completedWorkout ? AppStrings.yes : AppStrings.no,
          valueColor: s.completedWorkout ? AppColors.success : AppColors.error,
        ),
        if (s.feltPain)
          SessionRowData(
            icon: Icons.healing_rounded,
            label: AppStrings.pain,
            value: s.painLocation ?? AppStrings.yes,
            valueColor: AppColors.error,
          ),
        if (s.injury)
          SessionRowData(
            icon: Icons.personal_injury_rounded,
            label: AppStrings.injury,
            value: AppStrings.reported,
            valueColor: AppColors.error,
          ),
        if (s.notes != null && s.notes!.isNotEmpty)
          SessionRowData(
            icon: Icons.notes_rounded,
            label: AppStrings.notes,
            value: s.notes!,
            valueColor: AppColors.textSecondary,
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
