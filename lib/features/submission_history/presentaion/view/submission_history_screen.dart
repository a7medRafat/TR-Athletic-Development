import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';
import '../logic/submission_history_cubit.dart';
import '../logic/submission_history_state.dart';

class SubmissionHistoryScreen extends StatelessWidget {
  final String uid;

  const SubmissionHistoryScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    context.read<SubmissionHistoryCubit>().load(uid);
    return const _HistoryView();
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  String _fmt(DateTime dt) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = h.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionHistoryCubit, SubmissionHistoryState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              title: Text(
                AppStrings.submissionHistory,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              bottom: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: '${AppStrings.preTrainingSessions} (${state.preSessions.length})'),
                  Tab(text: '${AppStrings.postTrainingSessions} (${state.postSessions.length})'),
                ],
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _PreList(sessions: state.preSessions, fmt: _fmt),
                      _PostList(sessions: state.postSessions, fmt: _fmt),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ── Pre-Training List ─────────────────────────────────────────────────────────

class _PreList extends StatelessWidget {
  final List<PreTrainingModel> sessions;
  final String Function(DateTime) fmt;

  const _PreList({required this.sessions, required this.fmt});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return _emptyState();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: sessions.length,
      itemBuilder: (_, i) => _PreCard(session: sessions[i], fmt: fmt),
    );
  }
}

class _PreCard extends StatelessWidget {
  final PreTrainingModel session;
  final String Function(DateTime) fmt;

  const _PreCard({required this.session, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final readinessColor = _scale(s.readinessToTrain, 10, higher: true);
    return _SessionCard(
      date: fmt(s.createdAt),
      accentColor: AppColors.primary,
      readinessBanner: _ReadinessBanner(score: s.readinessToTrain, color: readinessColor),
      rows: [
        _RowData(
          icon: Icons.bedtime_rounded,
          label: AppStrings.sleep,
          value: '${s.hoursOfSleep.toStringAsFixed(s.hoursOfSleep == s.hoursOfSleep.roundToDouble() ? 0 : 1)} hrs',
          extra: AppStrings.sleepQualityDisplay(s.sleepQuality),
          valueColor: _scale(s.sleepQuality, 5, higher: true),
        ),
        _RowData(
          icon: Icons.battery_alert_rounded,
          label: AppStrings.fatigue,
          value: '${s.fatigueLevel}/10',
          valueColor: _scale(s.fatigueLevel, 10, higher: false),
        ),
        _RowData(
          icon: Icons.fitness_center_rounded,
          label: AppStrings.muscleSorenessShort,
          value: '${s.muscleSoreness}/10',
          valueColor: _scale(s.muscleSoreness, 10, higher: false),
        ),
        _RowData(
          icon: Icons.sentiment_satisfied_alt_rounded,
          label: AppStrings.mood,
          value: '${s.mood}/5',
          valueColor: _scale(s.mood, 5, higher: true),
        ),
        _RowData(
          icon: Icons.psychology_rounded,
          label: AppStrings.stress,
          value: '${s.stressLevel}/10',
          valueColor: _scale(s.stressLevel, 10, higher: false),
        ),
        _RowData(
          icon: Icons.bolt_rounded,
          label: AppStrings.energy,
          value: '${s.energyLevel}/10',
          valueColor: _scale(s.energyLevel, 10, higher: true),
        ),
        if (s.hasPainOrInjury)
          _RowData(
            icon: Icons.healing_rounded,
            label: AppStrings.painInjury,
            value: s.painLocation ?? AppStrings.yes,
            valueColor: AppColors.error,
          ),
      ],
    );
  }
}

// ── Readiness Banner ──────────────────────────────────────────────────────────

class _ReadinessBanner extends StatelessWidget {
  final int score;
  final Color color;

  const _ReadinessBanner({required this.score, required this.color});

  String get _label {
    if (score >= 7) return 'Ready';
    if (score >= 4) return 'Moderate';
    return 'Not Ready';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_run_rounded, size: 18.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.readiness,
                  style: TextStyle(fontSize: 11.sp, color: color.withValues(alpha: 0.8)),
                ),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          Text(
            '/10',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Post-Training List ────────────────────────────────────────────────────────

class _PostList extends StatelessWidget {
  final List<PostTrainingModel> sessions;
  final String Function(DateTime) fmt;

  const _PostList({required this.sessions, required this.fmt});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return _emptyState();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: sessions.length,
      itemBuilder: (_, i) => _PostCard(session: sessions[i], fmt: fmt),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostTrainingModel session;
  final String Function(DateTime) fmt;

  const _PostCard({required this.session, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return _SessionCard(
      date: fmt(s.createdAt),
      accentColor: AppColors.accent,
      rows: [
        _RowData(
          icon: Icons.speed_rounded,
          label: AppStrings.rpe,
          value: '${s.rpe}/10',
          valueColor: _scale(s.rpe, 10, higher: false),
          bold: true,
        ),
        _RowData(
          icon: Icons.battery_alert_rounded,
          label: AppStrings.fatigue,
          value: '${s.fatigue}/10',
          valueColor: _scale(s.fatigue, 10, higher: false),
        ),
        _RowData(
          icon: s.completedWorkout ? Icons.check_circle_rounded : Icons.cancel_rounded,
          label: AppStrings.completedWorkoutShort,
          value: s.completedWorkout ? AppStrings.yes : AppStrings.no,
          valueColor: s.completedWorkout ? AppColors.success : AppColors.error,
        ),
        if (s.feltPain)
          _RowData(
            icon: Icons.healing_rounded,
            label: AppStrings.pain,
            value: s.painLocation ?? AppStrings.yes,
            valueColor: AppColors.error,
          ),
        if (s.injury)
          _RowData(
            icon: Icons.personal_injury_rounded,
            label: AppStrings.injury,
            value: AppStrings.reported,
            valueColor: AppColors.error,
          ),
        if (s.notes != null && s.notes!.isNotEmpty)
          _RowData(
            icon: Icons.notes_rounded,
            label: AppStrings.notes,
            value: s.notes!,
            valueColor: AppColors.textSecondary,
          ),
      ],
    );
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final String date;
  final Color accentColor;
  final List<_RowData> rows;
  final Widget? readinessBanner;

  const _SessionCard({
    required this.date,
    required this.accentColor,
    required this.rows,
    this.readinessBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 14.sp, color: accentColor),
                SizedBox(width: 6.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
            child: Column(
              children: rows
                  .map(
                    (r) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: (r.valueColor ?? AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              r.icon,
                              size: 15.sp,
                              color: r.valueColor ?? AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              r.label,
                              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                            ),
                          ),
                          if (r.extra != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                r.extra!,
                                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                              ),
                            ),
                          Text(
                            r.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: r.bold ? FontWeight.w700 : FontWeight.w600,
                              color: r.valueColor ?? AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ?readinessBanner,
        ],
      ),
    );
  }
}

class _RowData {
  final IconData icon;
  final String label;
  final String value;
  final String? extra;
  final Color? valueColor;
  final bool bold;

  const _RowData({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
    this.valueColor,
    this.bold = false,
  });
}

Widget _emptyState() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 52, color: AppColors.textHint),
        const SizedBox(height: 10),
        Text(
          AppStrings.noHistory,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    ),
  );
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
