import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/labeled_slider_widget.dart';
import '../../../../core/widgets/pain_input_widget.dart';
import '../../../../core/widgets/radio_question_widget.dart';
import '../logic/pre_training_cubit.dart';
import '../logic/pre_training_state.dart';

class PreTrainingScreen extends StatelessWidget {
  const PreTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PreTrainingCubit>(),
      child: const _PreTrainingView(),
    );
  }
}

class _PreTrainingView extends StatelessWidget {
  const _PreTrainingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PreTrainingCubit, PreTrainingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(AppStrings.submitSuccess),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
          Navigator.of(context).pop();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PreTrainingCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.preTrainingTitle),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledSliderWidget(
                        title: AppStrings.sleepQuality,
                        value: state.sleepQuality.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        minLabel: AppStrings.veryBad,
                        maxLabel: AppStrings.excellent,
                        onChanged: (v) => cubit.updateSleepQuality(v.round()),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.hoursOfSleep,
                        value: state.hoursOfSleep,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        minLabel: '0 hrs',
                        maxLabel: '12 hrs',
                        valueFormatter: (v) =>
                            '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1)} hrs',
                        onChanged: (v) => cubit.updateHoursOfSleep(v),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.fatigueLevel,
                        value: state.fatigueLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) => cubit.updateFatigueLevel(v.round()),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.muscleSoreness,
                        value: state.muscleSoreness.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) => cubit.updateMuscleSoreness(v.round()),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.mood,
                        value: state.mood.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        minLabel: AppStrings.veryBad,
                        maxLabel: AppStrings.excellent,
                        onChanged: (v) => cubit.updateMood(v.round()),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.stressLevel,
                        value: state.stressLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) => cubit.updateStressLevel(v.round()),
                      ),
                      LabeledSliderWidget(
                        title: AppStrings.energyLevel,
                        value: state.energyLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) => cubit.updateEnergyLevel(v.round()),
                      ),
                      RadioQuestionWidget(
                        question: AppStrings.painOrInjury,
                        value: state.hasPainOrInjury,
                        onChanged: cubit.updateHasPainOrInjury,
                      ),
                      if (state.hasPainOrInjury)
                        PainInputWidget(
                          value: state.painLocation,
                          onChanged: cubit.updatePainLocation,
                        ),
                      LabeledSliderWidget(
                        title: AppStrings.readinessToTrain,
                        value: state.readinessToTrain.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) =>
                            cubit.updateReadinessToTrain(v.round()),
                      ),
                      SizedBox(height: 16.h),
                      _SubmitButton(onPressed: cubit.submit),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14.r),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  AppStrings.submit,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
