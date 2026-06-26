import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
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

class _AdminView extends StatelessWidget {
  const _AdminView();

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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

  void _showRejectDialog(
      BuildContext context, String uid, AdminUsersCubit cubit) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: const Text(AppStrings.rejectConfirm),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.rejectionReason,
            hintText: AppStrings.rejectionReasonHint,
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cubit.rejectUser(uid, reason: reasonCtrl.text.trim());
            },
            child: const Text(
              AppStrings.reject,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
    return BlocConsumer<AdminUsersCubit, AdminUsersState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            margin: EdgeInsets.all(16.w),
          ));
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            margin: EdgeInsets.all(16.w),
          ));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AdminUsersCubit>();
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text(AppStrings.adminDashboard),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => _confirmLogout(context),
                ),
              ],
              bottom: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(AppStrings.requests),
                        if (state.pendingCount > 0) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${state.pendingCount}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: AppStrings.allUsers),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _RequestsTab(
                  state: state,
                  cubit: cubit,
                  onApprove: (uid, name) => _showConfirmDialog(
                    context,
                    title: AppStrings.approveConfirm,
                    message: 'Approve $name?',
                    onConfirm: () => cubit.approveUser(uid),
                  ),
                  onReject: (uid) => _showRejectDialog(context, uid, cubit),
                  onTap: (uid) => _goToDetail(context, uid),
                ),
                _UsersTab(
                  state: state,
                  cubit: cubit,
                  onToggle: (user) {
                    final newStatus =
                        user.isDisabled ? 'approved' : 'disabled';
                    _showConfirmDialog(
                      context,
                      title: user.isDisabled
                          ? AppStrings.enableConfirm
                          : AppStrings.disableConfirm,
                      message:
                          user.fullName.isNotEmpty ? user.fullName : user.email,
                      onConfirm: () =>
                          cubit.setUserStatus(user.uid, newStatus),
                    );
                  },
                  onTap: (uid) => _goToDetail(context, uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToDetail(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUserDetailScreen(uid: uid)),
    );
  }
}

// ── Requests Tab ─────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  final AdminUsersState state;
  final AdminUsersCubit cubit;
  final void Function(String uid, String name) onApprove;
  final void Function(String uid) onReject;
  final void Function(String uid) onTap;

  const _RequestsTab({
    required this.state,
    required this.cubit,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final pending = state.allUsers.where((u) => u.isPending).toList();
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56.sp, color: AppColors.textHint),
            SizedBox(height: 12.h),
            Text(
              AppStrings.noRequests,
              style: TextStyle(
                  fontSize: 15.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: pending.length,
      itemBuilder: (_, i) {
        final user = pending[i];
        return UserRequestCardWidget(
          user: user,
          onTap: () => onTap(user.uid),
          onApprove: () => onApprove(
            user.uid,
            user.fullName.isNotEmpty ? user.fullName : user.email,
          ),
          onReject: () => onReject(user.uid),
        );
      },
    );
  }
}

// ── Users Tab ────────────────────────────────────────────────────────────────

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
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
                onChanged: cubit.setSearch,
              ),
              SizedBox(height: 10.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in [
                      ('all', 'All'),
                      ('approved', 'Approved'),
                      ('pending', 'Pending'),
                      ('rejected', 'Rejected'),
                      ('disabled', 'Disabled'),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
