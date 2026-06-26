import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

enum SliderColorMode { higherIsBetter, lowerIsBetter, neutral }

class LabeledSliderWidget extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? minLabel;
  final String? maxLabel;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;
  final SliderColorMode colorMode;

  const LabeledSliderWidget({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.minLabel,
    this.maxLabel,
    required this.onChanged,
    this.valueFormatter,
    this.colorMode = SliderColorMode.neutral,
  });

  String _formatValue(double v) {
    if (valueFormatter != null) return valueFormatter!(v);
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  Color _computeColor() {
    if (colorMode == SliderColorMode.neutral) return AppColors.primary;
    final ratio = (value - min) / (max - min);
    if (colorMode == SliderColorMode.higherIsBetter) {
      if (ratio >= 0.65) return AppColors.success;
      if (ratio >= 0.35) return AppColors.warning;
      return AppColors.error;
    } else {
      if (ratio <= 0.35) return AppColors.success;
      if (ratio <= 0.65) return AppColors.warning;
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _computeColor();

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _formatValue(value),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              inactiveTrackColor: color.withValues(alpha: 0.18),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          if (minLabel != null || maxLabel != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (minLabel != null)
                    Text(
                      minLabel!,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                  if (maxLabel != null)
                    Text(
                      maxLabel!,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
