import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../data/models/admin_user_model.dart';
import '../logic/admin_user_detail_state.dart';
import 'status_badge_widget.dart';

class PlayerProfileHeaderWidget extends StatelessWidget {
  final AdminUserModel user;
  final AdminUserDetailState state;
  final String Function(DateTime) formatDate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggle;

  const PlayerProfileHeaderWidget({
    super.key,
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
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: user.isDisabled ? AppColors.success : AppColors.error,
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
