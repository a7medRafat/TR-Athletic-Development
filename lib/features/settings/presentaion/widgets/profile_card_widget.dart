import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';

class ProfileCardWidget extends StatelessWidget {
  final UserProfileModel? profile;
  final String? email;

  const ProfileCardWidget({
    super.key,
    required this.profile,
    required this.email,
  });

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
    final displayName = profile?.fullName;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(displayName, email),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          if (displayName != null && displayName.isNotEmpty)
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          SizedBox(height: 8.h),
          if (email != null && email!.isNotEmpty)
            _InfoRow(icon: Icons.email_outlined, label: email!),
          if (profile != null && profile!.phoneNumber.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: profile!.phoneNumber,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.textSecondary),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
