import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/readiness_calculator.dart';
import '../../data/models/pre_training_model.dart';
import '../../data/repositories/pre_training_repo.dart';
import 'pre_training_state.dart';

class PreTrainingCubit extends Cubit<PreTrainingState> {
  final PreTrainingRepo _repo;

  PreTrainingCubit(this._repo) : super(const PreTrainingState());

  void updateSleepQuality(int value) =>
      emit(state.copyWith(sleepQuality: value));

  void updateHoursOfSleep(double value) =>
      emit(state.copyWith(hoursOfSleep: value));

  void updateFatigueLevel(int value) =>
      emit(state.copyWith(fatigueLevel: value));

  void updateMuscleSoreness(int value) =>
      emit(state.copyWith(muscleSoreness: value));

  void updateMood(int value) => emit(state.copyWith(mood: value));

  void updateStressLevel(int value) =>
      emit(state.copyWith(stressLevel: value));

  void updateEnergyLevel(int value) =>
      emit(state.copyWith(energyLevel: value));

  void updateHasPainOrInjury(bool value) => emit(
        state.copyWith(
          hasPainOrInjury: value,
          painLocation: value ? state.painLocation : '',
        ),
      );

  void updatePainLocation(String value) =>
      emit(state.copyWith(painLocation: value));

  void updateReadinessToTrain(int value) =>
      emit(state.copyWith(readinessToTrain: value));

  Future<void> submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final now = DateTime.now();

    // Build model with placeholder readiness so calculator can run
    final draftModel = PreTrainingModel(
      uid: uid,
      sleepQuality: state.sleepQuality,
      hoursOfSleep: state.hoursOfSleep,
      fatigueLevel: state.fatigueLevel,
      muscleSoreness: state.muscleSoreness,
      mood: state.mood,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      hasPainOrInjury: state.hasPainOrInjury,
      painLocation: state.hasPainOrInjury ? state.painLocation : null,
      readinessToTrain: 5,
      createdAt: now,
    );

    final model = PreTrainingModel(
      uid: uid,
      sleepQuality: state.sleepQuality,
      hoursOfSleep: state.hoursOfSleep,
      fatigueLevel: state.fatigueLevel,
      muscleSoreness: state.muscleSoreness,
      mood: state.mood,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      hasPainOrInjury: state.hasPainOrInjury,
      painLocation: state.hasPainOrInjury ? state.painLocation : null,
      readinessToTrain: ReadinessCalculator.calculate(draftModel),
      createdAt: now,
    );

    final result = await _repo.submit(model);

    result.when(
      success: (_) => emit(
        state.copyWith(isLoading: false, isSuccess: true),
      ),
      failure: (error) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.message ?? 'Submission failed',
        ),
      ),
    );
  }

  void reset() => emit(const PreTrainingState());
}
