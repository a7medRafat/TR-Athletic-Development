import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../logic/settings_cubit.dart';
import '../logic/settings_state.dart';
import '../widgets/profile_card_widget.dart';
import 'update_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<SettingsCubit>().signOut();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              children: [
                ProfileCardWidget(
                  profile: state.profile,
                  email: state.email,
                ),
                SizedBox(height: 24.h),
                Container(
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
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                        ),
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          AppStrings.editProfile,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UpdateProfileScreen(profile: state.profile),
                            ),
                          );
                          if (updated == true && context.mounted) {
                            context.read<SettingsCubit>().loadProfile();
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                        indent: 16.w,
                        endIndent: 16.w,
                        color: AppColors.border,
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16.r),
                          ),
                        ),
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          AppStrings.logout,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.error,
                          size: 20.sp,
                        ),
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
