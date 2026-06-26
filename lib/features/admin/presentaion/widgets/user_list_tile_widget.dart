import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/readiness_calculator.dart';
import '../../data/models/admin_user_model.dart';
import 'status_badge_widget.dart';

class UserListTileWidget extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const UserListTileWidget({
    super.key,
    required this.user,
    required this.onTap,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = user.isDisabled;
    final score = user.lastReadinessScore;
    final hasScore = score != null;
    final notReady = hasScore && !ReadinessCalculator.isReady(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with red dot when not ready
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDisabled ? AppColors.border : AppColors.primaryLight,
                  radius: 20.r,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ),
                if (notReady)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user.isApproved) ...[
                        SizedBox(width: 4.w),
                        Icon(Icons.verified_rounded,
                            size: 14.sp, color: AppColors.success),
                      ],
                    ],
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            StatusBadgeWidget(status: user.status),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onToggleStatus,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isDisabled
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  size: 16.sp,
                  color: isDisabled ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
