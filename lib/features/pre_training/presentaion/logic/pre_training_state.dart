import 'package:equatable/equatable.dart';

class PreTrainingState extends Equatable {
  final int sleepQuality;
  final double hoursOfSleep;
  final int fatigueLevel;
  final int muscleSoreness;
  final int mood;
  final int stressLevel;
  final int energyLevel;
  final bool hasPainOrInjury;
  final String painLocation;
  final int readinessToTrain;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const PreTrainingState({
    this.sleepQuality = 3,
    this.hoursOfSleep = 6.0,
    this.fatigueLevel = 5,
    this.muscleSoreness = 5,
    this.mood = 3,
    this.stressLevel = 5,
    this.energyLevel = 5,
    this.hasPainOrInjury = false,
    this.painLocation = '',
    this.readinessToTrain = 5,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  PreTrainingState copyWith({
    int? sleepQuality,
    double? hoursOfSleep,
    int? fatigueLevel,
    int? muscleSoreness,
    int? mood,
    int? stressLevel,
    int? energyLevel,
    bool? hasPainOrInjury,
    String? painLocation,
    int? readinessToTrain,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) =>
      PreTrainingState(
        sleepQuality: sleepQuality ?? this.sleepQuality,
        hoursOfSleep: hoursOfSleep ?? this.hoursOfSleep,
        fatigueLevel: fatigueLevel ?? this.fatigueLevel,
        muscleSoreness: muscleSoreness ?? this.muscleSoreness,
        mood: mood ?? this.mood,
        stressLevel: stressLevel ?? this.stressLevel,
        energyLevel: energyLevel ?? this.energyLevel,
        hasPainOrInjury: hasPainOrInjury ?? this.hasPainOrInjury,
        painLocation: painLocation ?? this.painLocation,
        readinessToTrain: readinessToTrain ?? this.readinessToTrain,
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        sleepQuality,
        hoursOfSleep,
        fatigueLevel,
        muscleSoreness,
        mood,
        stressLevel,
        energyLevel,
        hasPainOrInjury,
        painLocation,
        readinessToTrain,
        isLoading,
        isSuccess,
        errorMessage,
      ];
}
