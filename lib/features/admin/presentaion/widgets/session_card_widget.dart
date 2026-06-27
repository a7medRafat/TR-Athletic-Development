import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class SessionRowData {
  final IconData icon;
  final String label;
  final String value;
  final String? extra;
  final Color? valueColor;
  final bool bold;

  const SessionRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
    this.valueColor,
    this.bold = false,
  });
}

class SessionCardWidget extends StatelessWidget {
  final String date;
  final Color accentColor;
  final List<SessionRowData> rows;
  final Widget? readinessBanner;

  const SessionCardWidget({
    super.key,
    required this.date,
    required this.accentColor,
    required this.rows,
    this.readinessBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 14.sp, color: accentColor),
                SizedBox(width: 6.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
            child: Column(
              children: rows
                  .map(
                    (r) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: (r.valueColor ?? AppColors.primary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              r.icon,
                              size: 15.sp,
                              color: r.valueColor ?? AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              r.label,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (r.extra != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                r.extra!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          Text(
                            r.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  r.bold ? FontWeight.w700 : FontWeight.w600,
                              color: r.valueColor ?? AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (readinessBanner != null) readinessBanner!,
        ],
      ),
    );
  }
}
