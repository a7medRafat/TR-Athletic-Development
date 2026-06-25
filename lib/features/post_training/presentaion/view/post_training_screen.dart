import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../pre_training/presentaion/widgets/labeled_slider_widget.dart';
import '../../../pre_training/presentaion/widgets/pain_input_widget.dart';
import '../../../pre_training/presentaion/widgets/radio_question_widget.dart';
import '../logic/post_training_cubit.dart';
import '../logic/post_training_state.dart';
import '../widgets/notes_field_widget.dart';

class PostTrainingScreen extends StatelessWidget {
  const PostTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostTrainingCubit>(),
      child: const _PostTrainingView(),
    );
  }
}

class _PostTrainingView extends StatelessWidget {
  const _PostTrainingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostTrainingCubit, PostTrainingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppStrings.submitSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<PostTrainingCubit>().reset();
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
        final cubit = context.read<PostTrainingCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.postTrainingTitle),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // RPE: 1 → 10
                      LabeledSliderWidget(
                        title: AppStrings.rpe,
                        value: state.rpe.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: 'Very Easy',
                        maxLabel: 'Max Effort',
                        onChanged: (v) => cubit.updateRpe(v.round()),
                      ),

                      // Did you complete the workout?
                      RadioQuestionWidget(
                        question: AppStrings.completedWorkout,
                        value: state.completedWorkout,
                        onChanged: cubit.updateCompletedWorkout,
                      ),

                      // Did you feel pain?
                      RadioQuestionWidget(
                        question: AppStrings.feltPain,
                        value: state.feltPain,
                        onChanged: cubit.updateFeltPain,
                      ),

                      // Pain location (conditional)
                      if (state.feltPain)
                        PainInputWidget(
                          value: state.painLocation,
                          onChanged: cubit.updatePainLocation,
                        ),

                      // Did injury happen?
                      RadioQuestionWidget(
                        question: AppStrings.injuryOccurred,
                        value: state.injury,
                        onChanged: cubit.updateInjury,
                      ),

                      // Current Fatigue: 1 → 5
                      LabeledSliderWidget(
                        title: AppStrings.currentFatigue,
                        value: state.fatigue.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        minLabel: AppStrings.low,
                        maxLabel: AppStrings.high,
                        onChanged: (v) => cubit.updateFatigue(v.round()),
                      ),

                      // Notes (max 500 chars)
                      NotesFieldWidget(
                        value: state.notes,
                        onChanged: cubit.updateNotes,
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
