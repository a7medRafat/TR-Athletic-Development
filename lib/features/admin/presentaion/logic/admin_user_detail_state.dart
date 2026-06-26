import 'package:equatable/equatable.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../data/models/admin_user_model.dart';

class AdminUserDetailState extends Equatable {
  final AdminUserModel? user;
  final List<PreTrainingModel> preSessions;
  final List<PostTrainingModel> postSessions;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AdminUserDetailState({
    this.user,
    this.preSessions = const [],
    this.postSessions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  int get totalSessions => preSessions.length + postSessions.length;

  double get avgReadiness {
    if (preSessions.isEmpty) return 0;
    return preSessions.map((s) => s.readinessToTrain).reduce((a, b) => a + b) /
        preSessions.length;
  }

  double get avgRpe {
    if (postSessions.isEmpty) return 0;
    return postSessions.map((s) => s.rpe).reduce((a, b) => a + b) /
        postSessions.length;
  }

  // Training Load = sum of (rpe × trainingDuration) for sessions that have duration
  double get totalTrainingLoad {
    final withDuration = postSessions.where((s) => s.trainingDuration != null);
    if (withDuration.isEmpty) return 0;
    return withDuration
        .map((s) => s.rpe * s.trainingDuration!)
        .reduce((a, b) => a + b);
  }

  int get totalInjuries =>
      postSessions.where((s) => s.injury).length;

  DateTime? get lastActivity {
    final dates = [
      ...preSessions.map((s) => s.createdAt),
      ...postSessions.map((s) => s.createdAt),
    ];
    if (dates.isEmpty) return null;
    return dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  AdminUserDetailState copyWith({
    AdminUserModel? user,
    List<PreTrainingModel>? preSessions,
    List<PostTrainingModel>? postSessions,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      AdminUserDetailState(
        user: user ?? this.user,
        preSessions: preSessions ?? this.preSessions,
        postSessions: postSessions ?? this.postSessions,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );

  @override
  List<Object?> get props => [
        user,
        preSessions,
        postSessions,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
