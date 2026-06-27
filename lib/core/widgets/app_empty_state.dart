import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? subtitle;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52.sp, color: AppColors.textHint),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
