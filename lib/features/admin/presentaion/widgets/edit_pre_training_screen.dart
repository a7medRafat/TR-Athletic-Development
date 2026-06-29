import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/readiness_calculator.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../../../../core/widgets/labeled_slider_widget.dart'
    show LabeledSliderWidget, SliderColorMode;
import '../../../../core/widgets/pain_input_widget.dart';
import '../../../../core/widgets/radio_question_widget.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';

class EditPreTrainingScreen extends StatefulWidget {
  final PreTrainingModel session;
  final void Function(PreTrainingModel updated) onSave;

  const EditPreTrainingScreen({
    super.key,
    required this.session,
    required this.onSave,
  });

  @override
  State<EditPreTrainingScreen> createState() => _EditPreTrainingScreenState();
}

class _EditPreTrainingScreenState extends State<EditPreTrainingScreen> {
  late int _sleepQuality;
  late double _hoursOfSleep;
  late int _fatigueLevel;
  late int _muscleSoreness;
  late int _mood;
  late int _stressLevel;
  late int _energyLevel;
  late bool _hasPainOrInjury;
  late String _painLocation;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _sleepQuality = s.sleepQuality;
    _hoursOfSleep = s.hoursOfSleep;
    _fatigueLevel = s.fatigueLevel;
    _muscleSoreness = s.muscleSoreness;
    _mood = s.mood;
    _stressLevel = s.stressLevel;
    _energyLevel = s.energyLevel;
    _hasPainOrInjury = s.hasPainOrInjury;
    _painLocation = s.painLocation ?? '';
  }

  void _save() {
    // Placeholder readiness so the calculator (which ignores this field) can run.
    final draft = PreTrainingModel(
      id: widget.session.id,
      uid: widget.session.uid,
      sleepQuality: _sleepQuality,
      hoursOfSleep: _hoursOfSleep,
      fatigueLevel: _fatigueLevel,
      muscleSoreness: _muscleSoreness,
      mood: _mood,
      stressLevel: _stressLevel,
      energyLevel: _energyLevel,
      hasPainOrInjury: _hasPainOrInjury,
      painLocation: _hasPainOrInjury ? _painLocation : null,
      readinessToTrain: 5,
      createdAt: widget.session.createdAt,
    );

    final updated = PreTrainingModel(
      id: draft.id,
      uid: draft.uid,
      sleepQuality: draft.sleepQuality,
      hoursOfSleep: draft.hoursOfSleep,
      fatigueLevel: draft.fatigueLevel,
      muscleSoreness: draft.muscleSoreness,
      mood: draft.mood,
      stressLevel: draft.stressLevel,
      energyLevel: draft.energyLevel,
      hasPainOrInjury: draft.hasPainOrInjury,
      painLocation: draft.painLocation,
      readinessToTrain: ReadinessCalculator.calculate(draft),
      createdAt: draft.createdAt,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editPreTrainingSession)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledSliderWidget(
              title: AppStrings.sleepQuality,
              value: _sleepQuality.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.veryBad,
              maxLabel: AppStrings.excellent,
              colorMode: SliderColorMode.higherIsBetter,
              onChanged: (v) => setState(() => _sleepQuality = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.hoursOfSleep,
              value: _hoursOfSleep,
              min: 0,
              max: 12,
              divisions: 24,
              minLabel: AppStrings.zeroHrs,
              maxLabel: AppStrings.twelveHrs,
              colorMode: SliderColorMode.higherIsBetter,
              valueFormatter: (v) =>
                  '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1)} hrs',
              onChanged: (v) => setState(() => _hoursOfSleep = v),
            ),
            LabeledSliderWidget(
              title: AppStrings.fatigueLevel,
              value: _fatigueLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.low,
              maxLabel: AppStrings.high,
              colorMode: SliderColorMode.lowerIsBetter,
              onChanged: (v) => setState(() => _fatigueLevel = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.muscleSoreness,
              value: _muscleSoreness.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.low,
              maxLabel: AppStrings.high,
              colorMode: SliderColorMode.lowerIsBetter,
              onChanged: (v) => setState(() => _muscleSoreness = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.mood,
              value: _mood.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.veryBad,
              maxLabel: AppStrings.excellent,
              colorMode: SliderColorMode.higherIsBetter,
              onChanged: (v) => setState(() => _mood = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.stressLevel,
              value: _stressLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.low,
              maxLabel: AppStrings.high,
              colorMode: SliderColorMode.lowerIsBetter,
              onChanged: (v) => setState(() => _stressLevel = v.round()),
            ),
            LabeledSliderWidget(
              title: AppStrings.energyLevel,
              value: _energyLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              minLabel: AppStrings.low,
              maxLabel: AppStrings.high,
              colorMode: SliderColorMode.higherIsBetter,
              onChanged: (v) => setState(() => _energyLevel = v.round()),
            ),
            RadioQuestionWidget(
              question: AppStrings.painOrInjury,
              value: _hasPainOrInjury,
              onChanged: (v) => setState(() {
                _hasPainOrInjury = v;
                if (!v) _painLocation = '';
              }),
            ),
            if (_hasPainOrInjury)
              PainInputWidget(
                value: _painLocation,
                onChanged: (v) => _painLocation = v,
              ),
            SizedBox(height: 16.h),
            AppSubmitButton(
              label: AppStrings.saveChanges,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
