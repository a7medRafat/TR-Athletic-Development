import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class DetailSkeletonWidget extends StatelessWidget {
  const DetailSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          title: Container(
            width: 120.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: AppColors.primaryLight,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 110.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 80.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                    (_) => Container(
                      width: 72.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 42.h,
            color: AppColors.surface,
            margin: EdgeInsets.only(top: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (_) => Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                height: 80.h,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
}
