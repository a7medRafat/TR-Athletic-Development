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
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = h.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $hour:$min $period';
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
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
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
                      const Tab(text: 'Overview'),
                      Tab(
                        text:
                            '${AppStrings.preTrainingSessions} (${state.preSessions.length})',
                      ),
                      Tab(
                        text:
                            '${AppStrings.postTrainingSessions} (${state.postSessions.length})',
                      ),
                    ],
                  ),
                ),
                if (state.user != null)
                  SliverToBoxAdapter(
                    child: _PlayerProfileHeader(
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
                          u.isDisabled
                              ? AppStrings.enableConfirm
                              : AppStrings.disableConfirm,
                          u.fullName.isNotEmpty ? u.fullName : u.email,
                          () => cubit.setUserStatus(
                            u.isDisabled ? 'approved' : 'disabled',
                          ),
                        );
                      },
                    ),
                  ),
              ],
              body: state.user == null
                  ? Center(child: Text(AppStrings.userNotFound))
                  : TabBarView(
                      children: [
                        _OverviewTab(state: state, fmt: _fmt),
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

// ── Player Profile Header ─────────────────────────────────────────────────────

class _PlayerProfileHeader extends StatelessWidget {
  final AdminUserModel user;
  final AdminUserDetailState state;
  final String Function(DateTime) formatDate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggle;

  const _PlayerProfileHeader({
    required this.user,
    required this.state,
    required this.formatDate,
    required this.onApprove,
    required this.onReject,
    required this.onToggle,
  });

  Color get _readinessColor {
    final score = user.lastReadinessScore ?? 0;
    if (score >= 7) return AppColors.success;
    if (score >= 4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + name + readiness badge ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.email,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user.phoneNumber.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user.phoneNumber,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: 6.h),
                      StatusBadgeWidget(status: user.status),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Readiness badge
                if (user.lastReadinessScore != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: _readinessColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: _readinessColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${user.lastReadinessScore}/10',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: _readinessColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          AppStrings.readiness,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _readinessColor,
                          ),
                        ),
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: _readinessColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // ── Physical stats row ────────────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                _PhysicalStat(
                  label: AppStrings.age,
                  value: user.age != null ? '${user.age}' : '—',
                ),
                _divider(),
                _PhysicalStat(
                  label: AppStrings.heightCm,
                  value: user.height != null
                      ? '${user.height!.toStringAsFixed(0)} cm'
                      : '—',
                ),
                _divider(),
                _PhysicalStat(
                  label: AppStrings.weightKg,
                  value: user.weight != null
                      ? '${user.weight!.toStringAsFixed(0)} kg'
                      : '—',
                ),
                _divider(),
                _PhysicalStat(
                  label: AppStrings.gender,
                  value: user.gender != null
                      ? '${user.gender![0].toUpperCase()}${user.gender!.substring(1)}'
                      : '—',
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Action buttons ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            child: user.isPending
                ? Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: AppStrings.approve,
                          icon: Icons.check_rounded,
                          color: AppColors.success,
                          onTap: onApprove,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _ActionButton(
                          label: AppStrings.reject,
                          icon: Icons.close_rounded,
                          color: AppColors.error,
                          onTap: onReject,
                        ),
                      ),
                    ],
                  )
                : _ActionButton(
                    label: user.isDisabled
                        ? AppStrings.enable
                        : AppStrings.disable,
                    icon: user.isDisabled
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: user.isDisabled
                        ? AppColors.success
                        : AppColors.error,
                    onTap: onToggle,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36.h, color: AppColors.border);
}

class _PhysicalStat extends StatelessWidget {
  final String label;
  final String value;

  const _PhysicalStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
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

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final AdminUserDetailState state;
  final String Function(DateTime) fmt;

  const _OverviewTab({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final avgFatigue = state.postSessions.isEmpty
        ? 0.0
        : state.postSessions.map((s) => s.fatigue).reduce((a, b) => a + b) /
              state.postSessions.length;

    final completedCount = state.postSessions
        .where((s) => s.completedWorkout)
        .length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats grid ────────────────────────────────────────────────
          _SectionTitle(title: AppStrings.analytics),
          SizedBox(height: 10.h),
          _StatsGrid(
            items: [
              _StatItem(
                label: AppStrings.trainingLoad,
                value: state.totalTrainingLoad > 0
                    ? state.totalTrainingLoad.toStringAsFixed(1)
                    : '—',
                icon: Icons.bolt_rounded,
                color: AppColors.accent,
              ),
              _StatItem(
                label: AppStrings.totalSubmissions,
                value: '${state.totalSessions}',
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
              _StatItem(
                label: AppStrings.avgRpe,
                value: state.avgRpe > 0 ? state.avgRpe.toStringAsFixed(1) : '—',
                icon: Icons.speed_rounded,
                color: _rpeColor(state.avgRpe),
              ),
              _StatItem(
                label: AppStrings.avgReadiness,
                value: state.avgReadiness > 0
                    ? state.avgReadiness.toStringAsFixed(1)
                    : '—',
                icon: Icons.directions_run_rounded,
                color: _readinessColor(state.avgReadiness),
              ),
              _StatItem(
                label: 'Avg. Fatigue',
                value: avgFatigue > 0 ? avgFatigue.toStringAsFixed(1) : '—',
                icon: Icons.battery_alert_rounded,
                color: _scale(avgFatigue.round(), 5, higher: false),
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

          // ── Recent pre-training ───────────────────────────────────────
          if (state.preSessions.isNotEmpty) ...[
            _SectionTitle(title: 'Latest Pre-Training'),
            SizedBox(height: 10.h),
            _PreCard(session: state.preSessions.first, fmt: fmt),
          ],

          // ── Recent post-training ──────────────────────────────────────
          if (state.postSessions.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _SectionTitle(title: 'Latest Post-Training'),
            SizedBox(height: 10.h),
            _PostCard(session: state.postSessions.first, fmt: fmt),
          ],

          if (state.preSessions.isEmpty && state.postSessions.isEmpty)
            SizedBox(height: 40.h),
          if (state.preSessions.isEmpty && state.postSessions.isEmpty)
            _emptyState(),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
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
      readinessBanner: _ReadinessBanner(
        score: s.readinessToTrain,
        color: readinessColor,
      ),
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
            child: Icon(
              Icons.directions_run_rounded,
              size: 18.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.readiness,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color.withValues(alpha: 0.8),
                  ),
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
        if (s.trainingDuration != null)
          _RowData(
            icon: Icons.timer_rounded,
            label: AppStrings.trainingDuration,
            value: '${s.trainingDuration!.round()} min',
            extra: 'Load: ${(s.rpe * s.trainingDuration!).toStringAsFixed(0)}',
            valueColor: AppColors.primary,
          ),
        _RowData(
          icon: Icons.battery_alert_rounded,
          label: AppStrings.fatigue,
          value: '${s.fatigue}/5',
          valueColor: _scale(s.fatigue, 5, higher: false),
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
