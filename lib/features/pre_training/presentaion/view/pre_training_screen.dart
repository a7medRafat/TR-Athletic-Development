import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../logic/pre_training_cubit.dart';
import '../logic/pre_training_state.dart';
import '../../../../core/widgets/labeled_slider_widget.dart';
import '../../../../core/widgets/pain_input_widget.dart';
import '../../../../core/widgets/radio_question_widget.dart';

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
              content: const Text(AppStrings.submitSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<PreTrainingCubit>().reset();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
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
                      // Sleep Quality: 1 → 5
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

                      // Hours of Sleep: 0 → 12
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

                      // Fatigue Level: 1 → 10
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

                      // Muscle Soreness (DOMS): 1 → 10
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

                      // Mood: 1 → 5
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

                      // Stress Level: 1 → 10
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

                      // Energy Level: 1 → 10
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

                      // Pain / Injury: Yes / No
                      RadioQuestionWidget(
                        question: AppStrings.painOrInjury,
                        value: state.hasPainOrInjury,
                        onChanged: cubit.updateHasPainOrInjury,
                      ),

                      // Pain location (conditional)
                      if (state.hasPainOrInjury)
                        PainInputWidget(
                          value: state.painLocation,
                          onChanged: cubit.updatePainLocation,
                        ),

                      // Readiness to Train: 1 → 10
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

                      SizedBox(height: 8.h),

                      // Submit
                      ElevatedButton(
                        onPressed: () => cubit.submit(),
                        child: const Text(AppStrings.submit),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
