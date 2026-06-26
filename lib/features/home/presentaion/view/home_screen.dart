import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../post_training/presentaion/view/post_training_screen.dart';
import '../../../pre_training/presentaion/view/pre_training_screen.dart';
import '../../../settings/data/models/user_profile_model.dart';
import '../../../settings/presentaion/logic/settings_cubit.dart';
import '../../../settings/presentaion/logic/settings_state.dart';
import '../../../settings/presentaion/view/update_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String _initials(String? name, String? fallbackEmail) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    if (fallbackEmail != null && fallbackEmail.isNotEmpty) {
      return fallbackEmail[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final displayName = state.profile?.fullName;
        final email = state.email;
        final initials = _initials(displayName, email);

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: _AppDrawer(
            displayName: displayName,
            email: email,
            initials: initials,
            profile: state.profile,
          ),
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
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  displayName ?? email ?? AppStrings.appName,
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
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Check-In",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Track your training readiness and recovery',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 28.h),
                _TrainingCard(
                  icon: Icons.self_improvement_rounded,
                  title: AppStrings.preTraining,
                  subtitle: 'Sleep, fatigue & readiness check',
                  color: AppColors.primary,
                  lightColor: AppColors.primaryLight,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PreTrainingScreen(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _TrainingCard(
                  icon: Icons.fitness_center_rounded,
                  title: AppStrings.postTraining,
                  subtitle: 'RPE, pain & recovery check',
                  color: AppColors.accent,
                  lightColor: AppColors.accent.withValues(alpha: 0.12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PostTrainingScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
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
        child: Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final String? displayName;
  final String? email;
  final String initials;
  final UserProfileModel? profile;

  const _AppDrawer({
    required this.displayName,
    required this.email,
    required this.initials,
    required this.profile,
  });

  void _confirmLogout(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
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
              await cubit.signOut();
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
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  if (displayName != null && displayName!.isNotEmpty)
                    Text(
                      displayName!,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if (email != null && email!.isNotEmpty)
                    Text(
                      email!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.sp),
              ),
              title: Text(
                AppStrings.editProfile,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20.sp),
              onTap: () async {
                Navigator.of(context).pop();
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateProfileScreen(profile: profile),
                  ),
                );
                if (updated == true && context.mounted) {
                  context.read<SettingsCubit>().loadProfile();
                }
              },
            ),
            Divider(indent: 16.w, endIndent: 16.w, color: AppColors.border),
            ListTile(
              leading: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp),
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
                _confirmLogout(context);
              },
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
