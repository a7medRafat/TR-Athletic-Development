import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../data/repositories/admin_repo.dart';
import '../logic/admin_user_detail_cubit.dart';
import '../logic/admin_user_detail_state.dart';
import '../widgets/detail_skeleton_widget.dart';
import '../widgets/edit_pre_training_screen.dart';
import '../widgets/medical_history_tab_widget.dart';
import '../widgets/overview_tab_widget.dart';
import '../widgets/player_profile_header_widget.dart';
import '../widgets/post_training_list_widget.dart';
import '../widgets/pre_training_list_widget.dart';
import '../widgets/workload_tab.dart';

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
    AppConfirmDialog.show(
      context,
      title: AppStrings.rejectConfirm,
      message: AppStrings.rejectionReason,
      confirmLabel: AppStrings.reject,
      confirmColor: AppColors.error,
      extraContent: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: AppStrings.rejectionReason,
          hintText: AppStrings.rejectionReasonHint,
        ),
        maxLines: 2,
      ),
      onConfirm: () => cubit.rejectUser(reason: ctrl.text.trim()),
    );
  }

  void _showConfirm(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    AppConfirmDialog.show(
      context,
      title: title,
      message: message,
      onConfirm: onConfirm,
    );
  }

  void _showDeleteSessionConfirm(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    AppConfirmDialog.show(
      context,
      title: AppStrings.deleteSession,
      message: AppStrings.deleteSessionConfirm,
      confirmLabel: AppStrings.deleteSession,
      confirmColor: AppColors.error,
      icon: Icons.delete_outline_rounded,
      onConfirm: onConfirm,
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
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Skeletonizer(
              enabled: true,
              child: const DetailSkeletonWidget(),
            ),
          );
        }

        return DefaultTabController(
          length: 5,
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
                ),
                if (state.user != null)
                  SliverToBoxAdapter(
                    child: PlayerProfileHeaderWidget(
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
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: AppColors.surface,
                    child: TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        const Tab(text: 'Overview'),
                        Tab(text: AppStrings.preTrainingSessions),
                        Tab(text: AppStrings.postTrainingSessions),
                        Tab(text: AppStrings.workloadMonitoring),
                        Tab(text: AppStrings.medicalHistory),
                      ],
                    ),
                  ),
                ),
              ],
              body: state.user == null
                  ? Center(child: Text(AppStrings.userNotFound))
                  : TabBarView(
                      children: [
                        OverviewTabWidget(state: state, fmt: _fmt),
                        PreTrainingListWidget(
                          sessions: state.preSessions,
                          fmt: _fmt,
                          onEdit: (session) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPreTrainingScreen(
                                session: session,
                                onSave: cubit.updatePreTrainingSession,
                              ),
                            ),
                          ),
                          onDelete: (session) => _showDeleteSessionConfirm(
                            context,
                            () => cubit.deletePreTrainingSession(session.id!),
                          ),
                        ),
                        PostTrainingListWidget(
                          sessions: state.postSessions,
                          fmt: _fmt,
                        ),
                        WorkloadTab(postSessions: state.postSessions),
                        MedicalHistoryTabWidget(
                          medicalHistory: state.user?.medicalHistory,
                        ),
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
