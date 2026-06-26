import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/post_training_model.dart';
import '../../data/repositories/post_training_repo.dart';
import 'post_training_state.dart';

class PostTrainingCubit extends Cubit<PostTrainingState> {
  final PostTrainingRepo _repo;

  PostTrainingCubit(this._repo) : super(const PostTrainingState());

  void updateRpe(int value) => emit(state.copyWith(rpe: value));

  void updateCompletedWorkout(bool value) =>
      emit(state.copyWith(completedWorkout: value));

  void updateFeltPain(bool value) => emit(
        state.copyWith(
          feltPain: value,
          painLocation: value ? state.painLocation : '',
        ),
      );

  void updatePainLocation(String value) =>
      emit(state.copyWith(painLocation: value));

  void updateInjury(bool value) => emit(state.copyWith(injury: value));

  void updateFatigue(int value) => emit(state.copyWith(fatigue: value));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  void updateTrainingDuration(double value) =>
      emit(state.copyWith(trainingDuration: value));

  Future<void> submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(errorMessage: 'User not authenticated'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final model = PostTrainingModel(
      uid: uid,
      rpe: state.rpe,
      completedWorkout: state.completedWorkout,
      feltPain: state.feltPain,
      painLocation: state.feltPain ? state.painLocation : null,
      injury: state.injury,
      fatigue: state.fatigue,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      trainingDuration: state.trainingDuration,
      createdAt: DateTime.now(),
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

  void reset() => emit(const PostTrainingState());
}
