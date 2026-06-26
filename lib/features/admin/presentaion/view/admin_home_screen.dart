import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/readiness_calculator.dart';
import '../logic/admin_users_cubit.dart';
import '../logic/admin_users_state.dart';
import '../widgets/user_list_tile_widget.dart';
import '../widgets/user_request_card_widget.dart';
import 'admin_user_detail_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminUsersCubit>(),
      child: const _AdminView(),
    );
  }
}

// ── Main View ─────────────────────────────────────────────────────────────────

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
  int _tab = 0;

  void _showLogoutConfirm() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(AppStrings.logout),
        content: Text(AppStrings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              FirebaseAuth.instance.signOut();
            },
            child: Text(
              AppStrings.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String uid, AdminUsersCubit cubit) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
              cubit.rejectUser(uid, reason: ctrl.text.trim());
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

  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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

  void _goToDetail(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUserDetailScreen(uid: uid)),
    );
  }

  String _adminInitials() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : 'A';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersCubit, AdminUsersState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(_snack(
            state.successMessage!, AppColors.success));
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(_snack(
            state.errorMessage!, AppColors.error));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AdminUsersCubit>();
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        final initials = _adminInitials();

        return Scaffold(
          backgroundColor: AppColors.background,

          // ── Drawer ──────────────────────────────────────────────────────
          drawer: _AdminDrawer(
            email: email,
            initials: initials,
            pendingCount: state.pendingCount,
            onRequests: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: _RequestsScreen(
                      onApprove: (uid, name) => _showConfirmDialog(
                        AppStrings.approveConfirm,
                        AppStrings.approveUser(name),
                        () => cubit.approveUser(uid),
                      ),
                      onReject: (uid) => _showRejectDialog(uid, cubit),
                      onTap: _goToDetail,
                    ),
                  ),
                ),
              );
            },
            onLogout: _showLogoutConfirm,
          ),

          // ── AppBar ──────────────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 1,
            shadowColor: AppColors.cardShadow,
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18.r,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.adminPanel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  email.isNotEmpty ? email : AppStrings.adminDashboard,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              if (state.pendingCount > 0)
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.notifications_rounded,
                          color: AppColors.textSecondary, size: 24.sp),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 16.r,
                          height: 16.r,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${state.pendingCount}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // ── Bottom Nav ───────────────────────────────────────────────────
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(fontSize: 11.sp),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: const Icon(Icons.people_rounded),
                label: AppStrings.usersTab,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart_rounded),
                label: AppStrings.statsTab,
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          body: IndexedStack(
            index: _tab,
            children: [
              _UsersTab(
                state: state,
                cubit: cubit,
                onToggle: (user) {
                  final newStatus = user.isDisabled ? 'approved' : 'disabled';
                  _showConfirmDialog(
                    user.isDisabled
                        ? AppStrings.enableConfirm
                        : AppStrings.disableConfirm,
                    user.fullName.isNotEmpty ? user.fullName : user.email,
                    () => cubit.setUserStatus(user.uid, newStatus),
                  );
                },
                onTap: _goToDetail,
              ),
              _StatsTab(state: state),
            ],
          ),
        );
      },
    );
  }

  SnackBar _snack(String msg, Color color) => SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
      );
}

// ── Admin Drawer ──────────────────────────────────────────────────────────────

class _AdminDrawer extends StatelessWidget {
  final String email;
  final String initials;
  final int pendingCount;
  final VoidCallback onRequests;
  final VoidCallback onLogout;

  const _AdminDrawer({
    required this.email,
    required this.initials,
    required this.pendingCount,
    required this.onRequests,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blue header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    radius: 32.r,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppStrings.administrator,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Requests tile
            ListTile(
              leading: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.inbox_rounded,
                    color: AppColors.warning, size: 20.sp),
              ),
              title: Text(
                AppStrings.requests,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pendingCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  SizedBox(width: 4.w),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 20.sp),
                ],
              ),
              onTap: onRequests,
            ),

            // Language tile
            ListTile(
              leading: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.language_rounded,
                    color: AppColors.primary, size: 20.sp),
              ),
              title: Text(
                AppStrings.language,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                context.locale.languageCode == 'ar'
                    ? AppStrings.arabic
                    : AppStrings.english,
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.textSecondary),
              ),
              onTap: () => _showLangPicker(context),
            ),

            Divider(indent: 16.w, endIndent: 16.w, color: AppColors.border),

            // Logout tile
            ListTile(
              leading: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20.sp),
              ),
              title: Text(
                AppStrings.logout,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),

            const Spacer(),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLangPicker(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(AppStrings.changeLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            label: AppStrings.english,
            selected: context.locale.languageCode == 'en',
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.of(ctx).pop();
            },
          ),
          SizedBox(height: 8.h),
          _LangOption(
            label: AppStrings.arabic,
            selected: context.locale.languageCode == 'ar',
            onTap: () {
              context.setLocale(const Locale('ar'));
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    ),
  );
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded,
                  color: AppColors.primary, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

// ── Requests Screen (pushed from drawer) ─────────────────────────────────────

class _RequestsScreen extends StatelessWidget {
  final void Function(String uid, String name) onApprove;
  final void Function(String uid) onReject;
  final void Function(String uid) onTap;

  const _RequestsScreen({
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        final pending = state.allUsers.where((u) => u.isPending).toList();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              '${AppStrings.requests}'
              '${pending.isNotEmpty ? ' (${pending.length})' : ''}',
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : pending.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 56.sp, color: AppColors.textHint),
                          SizedBox(height: 12.h),
                          Text(
                            AppStrings.noRequests,
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      itemCount: pending.length,
                      itemBuilder: (_, i) {
                        final user = pending[i];
                        return UserRequestCardWidget(
                          user: user,
                          onTap: () => onTap(user.uid),
                          onApprove: () => onApprove(
                            user.uid,
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : user.email,
                          ),
                          onReject: () => onReject(user.uid),
                        );
                      },
                    ),
        );
      },
    );
  }
}

// ── Users Tab ─────────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final AdminUsersState state;
  final AdminUsersCubit cubit;
  final void Function(dynamic user) onToggle;
  final void Function(String uid) onTap;

  const _UsersTab({
    required this.state,
    required this.cubit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 20.sp),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
                onChanged: cubit.setSearch,
              ),
              SizedBox(height: 10.h),
              // Status filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in [
                      ('all', AppStrings.filterAll),
                      ('approved', AppStrings.statusApproved),
                      ('pending', AppStrings.statusPending),
                      ('rejected', AppStrings.statusRejected),
                      ('disabled', AppStrings.statusDisabled),
                    ])
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _FilterChip(
                          label: f.$2,
                          selected: state.statusFilter == f.$1,
                          onTap: () => cubit.setFilter(f.$1),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Readiness filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _FilterChip(
                        label: AppStrings.filterAll,
                        selected: state.readinessFilter == 'all',
                        onTap: () => cubit.setReadinessFilter('all'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _FilterChip(
                        label: AppStrings.readyToTrain,
                        selected: state.readinessFilter == 'ready',
                        onTap: () => cubit.setReadinessFilter('ready'),
                        activeColor: AppColors.success,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _FilterChip(
                        label: AppStrings.notReadyToTrain,
                        selected: state.readinessFilter == 'not_ready',
                        onTap: () => cubit.setReadinessFilter('not_ready'),
                        activeColor: AppColors.error,
                        icon: Icons.cancel_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.filtered.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noUsers,
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: state.filtered.length,
                      itemBuilder: (_, i) {
                        final user = state.filtered[i];
                        return UserListTileWidget(
                          user: user,
                          onTap: () => onTap(user.uid),
                          onToggleStatus: () => onToggle(user),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  final AdminUsersState state;

  const _StatsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final users = state.allUsers;
    final approved = users.where((u) => u.isApproved).length;
    final pending = users.where((u) => u.isPending).length;
    final rejected = users.where((u) => u.isRejected).length;
    final disabled = users.where((u) => u.isDisabled).length;

    final withScore = users
        .where((u) => u.lastReadinessScore != null)
        .toList();
    final readyCount = withScore
        .where((u) => ReadinessCalculator.isReady(u.lastReadinessScore!))
        .length;
    final notReadyCount = withScore.length - readyCount;
    final noDataCount = users.length - withScore.length;

    final avgScore = withScore.isEmpty
        ? 0.0
        : withScore
                .map((u) => u.lastReadinessScore!)
                .reduce((a, b) => a + b) /
            withScore.length;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        // User status breakdown
        _SectionTitle(title: AppStrings.userOverview, icon: Icons.people_rounded),
        SizedBox(height: 10.h),
        Row(
          children: [
            _StatCard(
              label: AppStrings.total,
              value: '${users.length}',
              icon: Icons.group_rounded,
              color: AppColors.primary,
            ),
            SizedBox(width: 10.w),
            _StatCard(
              label: AppStrings.active,
              value: '$approved',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _StatCard(
              label: AppStrings.statusPending,
              value: '$pending',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
            ),
            SizedBox(width: 10.w),
            _StatCard(
              label: AppStrings.rejectedDisabled,
              value: '${rejected + disabled}',
              icon: Icons.block_rounded,
              color: AppColors.error,
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Readiness overview
        _SectionTitle(
            title: AppStrings.readinessOverview, icon: Icons.directions_run_rounded),
        SizedBox(height: 10.h),
        _ReadinessCard(
          readyCount: readyCount,
          notReadyCount: notReadyCount,
          noDataCount: noDataCount,
          avgScore: avgScore,
          total: users.length,
        ),
        SizedBox(height: 24.h),

        // Breakdown bars
        if (withScore.isNotEmpty) ...[
          _SectionTitle(
              title: AppStrings.scoreDistribution, icon: Icons.bar_chart_rounded),
          SizedBox(height: 10.h),
          _ScoreDistribution(users: withScore),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  final int readyCount;
  final int notReadyCount;
  final int noDataCount;
  final double avgScore;
  final int total;

  const _ReadinessCard({
    required this.readyCount,
    required this.notReadyCount,
    required this.noDataCount,
    required this.avgScore,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final withData = readyCount + notReadyCount;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ReadinessStat(
                  label: AppStrings.ready,
                  value: '$readyCount',
                  color: AppColors.success),
              _VertDivider(),
              _ReadinessStat(
                  label: AppStrings.notReady,
                  value: '$notReadyCount',
                  color: AppColors.error),
              _VertDivider(),
              _ReadinessStat(
                  label: AppStrings.noData,
                  value: '$noDataCount',
                  color: AppColors.textHint),
              _VertDivider(),
              _ReadinessStat(
                  label: AppStrings.avgScore,
                  value: withData > 0
                      ? avgScore.toStringAsFixed(0)
                      : '—',
                  color: AppColors.primary),
            ],
          ),
          if (withData > 0) ...[
            SizedBox(height: 14.h),
            // Ready bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: SizedBox(
                height: 8.h,
                child: Row(
                  children: [
                    Flexible(
                      flex: readyCount,
                      child: Container(color: AppColors.success),
                    ),
                    Flexible(
                      flex: notReadyCount,
                      child: Container(color: AppColors.error),
                    ),
                    Flexible(
                      flex: noDataCount,
                      child: Container(color: AppColors.border),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.thresholdLabel(ReadinessCalculator.readyThreshold),
                  style: TextStyle(
                      fontSize: 10.sp, color: AppColors.textSecondary),
                ),
                Text(
                  withData > 0
                      ? AppStrings.percentReady(((readyCount / withData) * 100).round())
                      : '',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadinessStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReadinessStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style:
                TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36.h, color: AppColors.border);
}

class _ScoreDistribution extends StatelessWidget {
  final List<dynamic> users;

  const _ScoreDistribution({required this.users});

  @override
  Widget build(BuildContext context) {
    final buckets = [0, 0, 0, 0, 0]; // 0-19, 20-39, 40-59, 60-79, 80-100
    for (final u in users) {
      final s = u.lastReadinessScore as int;
      if (s < 20) buckets[0]++;
      else if (s < 40) buckets[1]++;
      else if (s < 60) buckets[2]++;
      else if (s < 80) buckets[3]++;
      else buckets[4]++;
    }
    final max = buckets.reduce((a, b) => a > b ? a : b);
    final labels = ['0-19', '20-39', '40-59', '60-79', '80+'];
    final colors = [
      AppColors.error,
      AppColors.error.withValues(alpha: 0.6),
      AppColors.warning,
      AppColors.success.withValues(alpha: 0.6),
      AppColors.success,
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) {
              final ratio = max == 0 ? 0.0 : buckets[i] / max;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      if (buckets[i] > 0)
                        Text(
                          '${buckets[i]}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: colors[i],
                          ),
                        ),
                      SizedBox(height: 4.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: (ratio * 80).clamp(4.0, 80.0).h,
                        decoration: BoxDecoration(
                          color: colors[i],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13.sp,
                color: selected ? Colors.white : color,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
