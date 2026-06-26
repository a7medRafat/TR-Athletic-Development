import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';

class UpdateProfileHeaderWidget extends StatelessWidget {
  final UserProfileModel? profile;

  const UpdateProfileHeaderWidget({super.key, required this.profile});

  String _initials() {
    final name = profile?.fullName;
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final name = profile?.fullName ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + 8.h, left: 12.w),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 44.h),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(),
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    'Update your personal information',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
