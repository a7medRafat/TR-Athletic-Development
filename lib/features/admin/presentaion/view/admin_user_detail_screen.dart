import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repositories/admin_repo.dart';
import '../logic/admin_user_detail_cubit.dart';
import '../logic/admin_user_detail_state.dart';
import '../widgets/status_badge_widget.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final String uid;

  const AdminUserDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUserDetailCubit(getIt<AdminRepo>(), uid: uid),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  String _fmt(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showRejectDialog(BuildContext context, AdminUserDetailCubit cubit) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(AppStrings.rejectConfirm),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: AppStrings.rejectionReason,
            hintText: AppStrings.rejectionReasonHint,
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cubit.rejectUser(reason: ctrl.text.trim());
            },
            child: Text(
              AppStrings.reject,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirm(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: Text(
              AppStrings.confirmAction,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUserDetailCubit, AdminUserDetailState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(_snackBar(state.successMessage!, AppColors.success));
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(_snackBar(state.errorMessage!, AppColors.error));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AdminUserDetailCubit>();

        if (state.isLoading && state.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                // ── Sticky AppBar with TabBar ─────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  title: Text(
                    AppStrings.userDetails,
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
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: '${AppStrings.preTrainingSessions} (${state.preSessions.length})'),
                      Tab(text: '${AppStrings.postTrainingSessions} (${state.postSessions.length})'),
                    ],
                  ),
                ),
                // ── Profile section (scrolls away) ───────────────────────
                if (state.user != null)
                  SliverToBoxAdapter(
                    child: _ProfileBanner(
                      user: state.user!,
                      state: state,
                      formatDate: _fmt,
                      onApprove: () => _showConfirm(
                        context,
                        AppStrings.approveConfirm,
                        state.user!.fullName.isNotEmpty
                            ? state.user!.fullName
                            : state.user!.email,
                        cubit.approveUser,
                      ),
                      onReject: () => _showRejectDialog(context, cubit),
                      onToggle: () {
                        final u = state.user!;
                        _showConfirm(
                          context,
                          u.isDisabled ? AppStrings.enableConfirm : AppStrings.disableConfirm,
                          u.fullName.isNotEmpty ? u.fullName : u.email,
                          () => cubit.setUserStatus(u.isDisabled ? 'approved' : 'disabled'),
                        );
                      },
                    ),
                  ),
              ],
              body: state.user == null
                  ? Center(child: Text(AppStrings.userNotFound))
                  : TabBarView(
                      children: [
                        _PreList(sessions: state.preSessions, fmt: _fmt),
                        _PostList(sessions: state.postSessions, fmt: _fmt),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  SnackBar _snackBar(String msg, Color color) => SnackBar(
    content: Text(msg),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    margin: EdgeInsets.all(16.w),
  );
}

// ── Profile Banner ────────────────────────────────────────────────────────────

class _ProfileBanner extends StatelessWidget {
  final AdminUserModel user;
  final AdminUserDetailState state;
  final String Function(DateTime) formatDate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggle;

  const _ProfileBanner({
    required this.user,
    required this.state,
    required this.formatDate,
    required this.onApprove,
    required this.onReject,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + info + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                radius: 28.r,
                child: Text(
                  user.initials,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : user.email,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (user.phoneNumber.isNotEmpty)
                      Text(
                        user.phoneNumber,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              StatusBadgeWidget(status: user.status),
            ],
          ),
          SizedBox(height: 14.h),
          // Stats row
          Row(
            children: [
              _StatBox(label: AppStrings.total, value: '${state.totalSessions}'),
              SizedBox(width: 8.w),
              _StatBox(
                label: AppStrings.avgReadiness,
                value: state.avgReadiness > 0
                    ? '${state.avgReadiness.toStringAsFixed(1)}/10'
                    : '—',
              ),
              SizedBox(width: 8.w),
              _StatBox(
                label: AppStrings.avgRpe,
                value: state.avgRpe > 0
                    ? '${state.avgRpe.toStringAsFixed(1)}/10'
                    : '—',
              ),
              SizedBox(width: 8.w),
              _StatBox(
                label: AppStrings.lastActive,
                value: state.lastActivity != null
                    ? formatDate(state.lastActivity!)
                    : '—',
                small: true,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Action buttons
          if (user.isPending)
            Row(
              children: [
                Expanded(
                  child: _BannerButton(
                    label: AppStrings.approve,
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onTap: onApprove,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _BannerButton(
                    label: AppStrings.reject,
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onTap: onReject,
                  ),
                ),
              ],
            )
          else
            _BannerButton(
              label: user.isDisabled ? AppStrings.enable : AppStrings.disable,
              icon: user.isDisabled
                  ? Icons.lock_open_rounded
                  : Icons.lock_outline_rounded,
              color: user.isDisabled ? AppColors.success : AppColors.error,
              onTap: onToggle,
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _StatBox({
    required this.label,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: small ? 10.sp : 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BannerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
    return _SessionCard(
      date: fmt(s.createdAt),
      accentColor: AppColors.primary,
      rows: [
        _RowData(
          icon: Icons.bedtime_rounded,
          label: AppStrings.sleep,
          value:
              '${s.hoursOfSleep.toStringAsFixed(s.hoursOfSleep == s.hoursOfSleep.roundToDouble() ? 0 : 1)} hrs',
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
        _RowData(
          icon: Icons.directions_run_rounded,
          label: AppStrings.readiness,
          value: '${s.readinessToTrain}/10',
          valueColor: _scale(s.readinessToTrain, 10, higher: true),
          bold: true,
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
          icon: s.completedWorkout
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
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

  const _SessionCard({
    required this.date,
    required this.accentColor,
    required this.rows,
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
          // Date header strip
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
                Icon(
                  Icons.calendar_month_rounded,
                  size: 14.sp,
                  color: accentColor,
                ),
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
          // Fields
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
                              color: (r.valueColor ?? AppColors.primary)
                                  .withValues(alpha: 0.1),
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
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (r.extra != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                r.extra!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          Text(
                            r.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: r.bold
                                  ? FontWeight.w700
                                  : FontWeight.w600,
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

// ── Helpers ───────────────────────────────────────────────────────────────────

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
