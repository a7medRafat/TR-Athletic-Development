import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../logic/admin_user_detail_state.dart';
import 'post_training_list_widget.dart';
import 'pre_training_list_widget.dart';

class OverviewTabWidget extends StatelessWidget {
  final AdminUserDetailState state;
  final String Function(DateTime) fmt;

  const OverviewTabWidget({
    super.key,
    required this.state,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final avgFatigue = state.postSessions.isEmpty
        ? 0.0
        : state.postSessions.map((s) => s.fatigue).reduce((a, b) => a + b) /
              state.postSessions.length;

    final completedCount =
        state.postSessions.where((s) => s.completedWorkout).length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          _StatsGrid(
            items: [
              // ── Readiness & performance ──
              _StatItem(
                label: AppStrings.avgReadiness,
                value: state.avgReadiness > 0
                    ? state.avgReadiness.toStringAsFixed(1)
                    : '—',
                icon: Icons.directions_run_rounded,
                color: _readinessColor(state.avgReadiness),
              ),
              _StatItem(
                label: AppStrings.avgRpe,
                value: state.avgRpe > 0
                    ? state.avgRpe.toStringAsFixed(1)
                    : '—',
                icon: Icons.speed_rounded,
                color: _rpeColor(state.avgRpe),
              ),
              _StatItem(
                label: AppStrings.trainingLoad,
                value: state.totalTrainingLoad > 0
                    ? state.totalTrainingLoad.toStringAsFixed(0)
                    : '—',
                icon: Icons.bolt_rounded,
                color: AppColors.accent,
              ),
              // ── Sessions ──
              _StatItem(
                label: 'Sessions',
                value: '${state.preSessions.length}',
                icon: Icons.bar_chart_rounded,
                color: AppColors.primary,
              ),
              _StatItem(
                label: AppStrings.preTrainingSessions,
                value: '${state.preSessions.length}',
                icon: Icons.self_improvement_rounded,
                color: AppColors.primary,
              ),
              _StatItem(
                label: AppStrings.postTrainingSessions,
                value: '${state.postSessions.length}',
                icon: Icons.fitness_center_rounded,
                color: AppColors.accent,
              ),
              // ── Recovery & health ──
              _StatItem(
                label: 'Avg. Fatigue',
                value: avgFatigue > 0 ? avgFatigue.toStringAsFixed(1) : '—',
                icon: Icons.battery_alert_rounded,
                color: _colorScale(avgFatigue.round(), 5, higher: false),
              ),
              _StatItem(
                label: 'Completed',
                value: state.postSessions.isEmpty
                    ? '—'
                    : '$completedCount/${state.postSessions.length}',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              _StatItem(
                label: AppStrings.totalInjuries,
                value: '${state.totalInjuries}',
                icon: Icons.personal_injury_rounded,
                color: state.totalInjuries > 0
                    ? AppColors.error
                    : AppColors.success,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (state.preSessions.isNotEmpty) ...[
            _SectionTitle(title: 'Latest Pre-Training'),
            SizedBox(height: 10.h),
            PreCardWidget(session: state.preSessions.first, fmt: fmt),
          ],
          if (state.postSessions.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _SectionTitle(title: 'Latest Post-Training'),
            SizedBox(height: 10.h),
            PostCardWidget(session: state.postSessions.first, fmt: fmt),
          ],
          if (state.preSessions.isEmpty && state.postSessions.isEmpty) ...[
            SizedBox(height: 40.h),
            AppEmptyState(message: AppStrings.noHistory),
          ],
        ],
      ),
    );
  }

  Color _rpeColor(double v) {
    if (v == 0) return AppColors.textSecondary;
    if (v >= 7) return AppColors.error;
    if (v >= 4) return AppColors.warning;
    return AppColors.success;
  }

  Color _readinessColor(double v) {
    if (v == 0) return AppColors.textSecondary;
    if (v >= 7) return AppColors.success;
    if (v >= 4) return AppColors.warning;
    return AppColors.error;
  }
}

Color _colorScale(int value, int max, {required bool higher}) {
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatsGrid extends StatelessWidget {
  final List<_StatItem> items;

  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(10.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(item.icon, size: 17.sp, color: item.color),
              ),
              SizedBox(height: 6.h),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: item.color == AppColors.textSecondary
                      ? AppColors.textPrimary
                      : item.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
