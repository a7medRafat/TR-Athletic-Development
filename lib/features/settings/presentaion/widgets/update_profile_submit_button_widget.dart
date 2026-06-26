import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../logic/update_profile_cubit.dart';
import '../logic/update_profile_state.dart';

class UpdateProfileSubmitButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasChanges;

  const UpdateProfileSubmitButtonWidget({
    super.key,
    required this.onPressed,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
      builder: (context, state) {
        final isEnabled = hasChanges && !state.isLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 54.h,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            color: isEnabled ? null : AppColors.border,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(14.r),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: state.isLoading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isEnabled) ...[
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            hasChanges ? AppStrings.saveChanges : 'No changes',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: isEnabled
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
