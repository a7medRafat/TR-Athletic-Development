import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../utils/app_strings.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final Color confirmColor;
  final IconData icon;
  final Color? iconColor;
  final Widget? extraContent;
  final bool showActions;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmColor = AppColors.primary,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor,
    this.extraContent,
    this.showActions = true,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
    String? cancelLabel,
    Color confirmColor = AppColors.primary,
    IconData icon = Icons.warning_amber_rounded,
    Color? iconColor,
    Widget? extraContent,
    bool showActions = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
        extraContent: extraContent,
        showActions: showActions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? confirmColor;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: resolvedIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: resolvedIconColor, size: 34.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (extraContent != null) ...[
              SizedBox(height: 14.h),
              extraContent!,
            ],
            if (showActions) ...[
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel ?? AppStrings.confirmAction,
                      color: confirmColor,
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel ?? AppStrings.cancel,
                      color: AppColors.background,
                      textColor: AppColors.textPrimary,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ] else
              SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
