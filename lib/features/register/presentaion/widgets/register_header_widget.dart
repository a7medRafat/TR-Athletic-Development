import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            size: 40.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppStrings.createAccount,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
