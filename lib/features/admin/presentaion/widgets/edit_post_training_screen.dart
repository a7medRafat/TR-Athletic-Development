import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../../../../core/widgets/labeled_slider_widget.dart'
    show LabeledSliderWidget, SliderColorMode;
import '../../../../core/widgets/pain_input_widget.dart';
import '../../../../core/widgets/radio_question_widget.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../../../features/post_training/presentaion/widgets/notes_field_widget.dart';

class EditPostTrainingScreen extends StatefulWidget {
  final PostTrainingModel session;
  final void Function(PostTrainingModel updated) onSave;

  const EditPostTrainingScreen({
    super.key,
    required this.session,
    required this.onSave,
  });

  @override
  State<EditPostTrainingScreen> createState() => _EditPostTrainingScreenState();
}

class _EditPostTrainingScreenState extends State<EditPostTrainingScreen> {
  late int _rpe;
  late double _trainingDuration;
  late bool _completedWorkout;
  late bool _feltPain;
  late String _painLocation;
  late bool _injury;
  late int _fatigue;
  late String _notes;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _rpe = s.rpe;
    _trainingDuration = s.trainingDuration ?? 60.0;
    _completedWorkout = s.completedWorkout;
    _feltPain = s.feltPain;
    _painLocation = s.painLocation ?? '';
    _injury = s.injury;
    _fatigue = s.fatigue;
    _notes = s.notes ?? '';
  }

  void _save() {
    final updated = PostTrainingModel(
      id: widget.session.id,
      uid: widget.session.uid,
      rpe: _rpe,
      completedWorkout: _completedWorkout,
      feltPain: _feltPain,
      painLocation: _feltPain ? _painLocation : null,
      injury: _injury,
      fatigue: _fatigue,
      notes: _notes.trim().isEmpty ? null : _notes.trim(),
      trainingDuration: _trainingDuration,
      createdAt: widget.session.createdAt,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editPostTrainingSession)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledSliderWidget(
              title: AppStrings.rpe,
              value: _rpe.toDouble(),
              min: 1,
              max: 9,
              divisions: 8,
              minLabel: AppStrings.veryEasy,
              maxLabel: AppStrings.maxEffort,
              colorMode: SliderColorMode.lowerIsBetter,
              onChanged: (v) => setState(() => _rpe = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.trainingDuration,
              value: _trainingDuration,
              min: 5,
              max: 150,
              divisions: 29,
              minLabel: '5 min',
              maxLabel: '150 min',
              colorMode: SliderColorMode.neutral,
              valueFormatter: (v) => '${v.round()} min',
              onChanged: (v) => setState(() => _trainingDuration = v.roundToDouble()),
            ),
            RadioQuestionWidget(
              question: AppStrings.completedWorkout,
              value: _completedWorkout,
              onChanged: (v) => setState(() => _completedWorkout = v),
            ),
            RadioQuestionWidget(
              question: AppStrings.feltPain,
              value: _feltPain,
              onChanged: (v) => setState(() {
                _feltPain = v;
                if (!v) _painLocation = '';
              }),
            ),
            if (_feltPain)
              PainInputWidget(
                value: _painLocation,
                onChanged: (v) => _painLocation = v,
              ),
            RadioQuestionWidget(
              question: AppStrings.injuryOccurred,
              value: _injury,
              onChanged: (v) => setState(() => _injury = v),
            ),
            LabeledSliderWidget(
              title: AppStrings.currentFatigue,
              value: _fatigue.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              minLabel: AppStrings.low,
              maxLabel: AppStrings.high,
              colorMode: SliderColorMode.lowerIsBetter,
              onChanged: (v) => setState(() => _fatigue = v.round()),
            ),
            NotesFieldWidget(
              value: _notes,
              onChanged: (v) => _notes = v,
            ),
            SizedBox(height: 16.h),
            AppSubmitButton(
              label: AppStrings.saveChanges,
              onPressed: _save,
              gradientColors: const [AppColors.accent, Color(0xFFE85A20)],
            ),
          ],
        ),
      ),
    );
  }
}
