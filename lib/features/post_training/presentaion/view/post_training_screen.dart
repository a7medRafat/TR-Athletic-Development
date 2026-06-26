import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../../../../core/widgets/labeled_slider_widget.dart';
import '../../../../core/widgets/pain_input_widget.dart';
import '../../../../core/widgets/radio_question_widget.dart';
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
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
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
        final cubit = context.read<PostTrainingCubit>();
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.postTrainingTitle)),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledSliderWidget(
                        title: AppStrings.rpe,
                        value: state.rpe.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        minLabel: AppStrings.veryEasy,
                        maxLabel: AppStrings.maxEffort,
                        onChanged: (v) => cubit.updateRpe(v.round()),
                      ),
                      RadioQuestionWidget(
                        question: AppStrings.completedWorkout,
                        value: state.completedWorkout,
                        onChanged: cubit.updateCompletedWorkout,
                      ),
                      RadioQuestionWidget(
                        question: AppStrings.feltPain,
                        value: state.feltPain,
                        onChanged: cubit.updateFeltPain,
                      ),
                      if (state.feltPain)
                        PainInputWidget(
                          value: state.painLocation,
                          onChanged: cubit.updatePainLocation,
                        ),
                      RadioQuestionWidget(
                        question: AppStrings.injuryOccurred,
                        value: state.injury,
                        onChanged: cubit.updateInjury,
                      ),
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
                      NotesFieldWidget(
                        value: state.notes,
                        onChanged: cubit.updateNotes,
                      ),
                      SizedBox(height: 16.h),
                      AppSubmitButton(
                        label: AppStrings.submit,
                        onPressed: cubit.submit,
                        gradientColors: const [
                          AppColors.accent,
                          Color(0xFFE85A20),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
