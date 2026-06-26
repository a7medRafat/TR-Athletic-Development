import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;
  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'approved') return const SizedBox.shrink();

    final (color, label) = switch (status) {
      'pending' => (AppColors.warning, AppStrings.statusPending),
      'rejected' => (AppColors.error, AppStrings.statusRejected),
      'disabled' => (AppColors.textSecondary, AppStrings.statusDisabled),
      _ => (AppColors.textSecondary, status),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
