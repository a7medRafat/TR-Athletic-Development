import 'package:equatable/equatable.dart';

class PostTrainingState extends Equatable {
  final int rpe;
  final bool completedWorkout;
  final bool feltPain;
  final String painLocation;
  final bool injury;
  final int fatigue;
  final String notes;
  final double trainingDuration;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const PostTrainingState({
    this.rpe = 5,
    this.completedWorkout = false,
    this.feltPain = false,
    this.painLocation = '',
    this.injury = false,
    this.fatigue = 3,
    this.notes = '',
    this.trainingDuration = 60.0,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  PostTrainingState copyWith({
    int? rpe,
    bool? completedWorkout,
    bool? feltPain,
    String? painLocation,
    bool? injury,
    int? fatigue,
    String? notes,
    double? trainingDuration,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) =>
      PostTrainingState(
        rpe: rpe ?? this.rpe,
        completedWorkout: completedWorkout ?? this.completedWorkout,
        feltPain: feltPain ?? this.feltPain,
        painLocation: painLocation ?? this.painLocation,
        injury: injury ?? this.injury,
        fatigue: fatigue ?? this.fatigue,
        notes: notes ?? this.notes,
        trainingDuration: trainingDuration ?? this.trainingDuration,
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        rpe,
        completedWorkout,
        feltPain,
        painLocation,
        injury,
        fatigue,
        notes,
        trainingDuration,
        isLoading,
        isSuccess,
        errorMessage,
      ];
}
