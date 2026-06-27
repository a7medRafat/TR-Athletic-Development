import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_strings.dart';

class ReadinessBannerWidget extends StatelessWidget {
  final int score;
  final Color color;

  const ReadinessBannerWidget({
    super.key,
    required this.score,
    required this.color,
  });

  String get _label {
    if (score >= 7) return 'Ready';
    if (score >= 4) return 'Moderate';
    return 'Not Ready';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_run_rounded,
              size: 18.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.readiness,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          Text(
            '/10',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
