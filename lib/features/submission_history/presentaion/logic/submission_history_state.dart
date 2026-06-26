import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';

class SubmissionHistoryState {
  final bool isLoading;
  final List<PreTrainingModel> preSessions;
  final List<PostTrainingModel> postSessions;
  final String? errorMessage;

  const SubmissionHistoryState({
    this.isLoading = false,
    this.preSessions = const [],
    this.postSessions = const [],
    this.errorMessage,
  });

  SubmissionHistoryState copyWith({
    bool? isLoading,
    List<PreTrainingModel>? preSessions,
    List<PostTrainingModel>? postSessions,
    String? errorMessage,
  }) =>
      SubmissionHistoryState(
        isLoading: isLoading ?? this.isLoading,
        preSessions: preSessions ?? this.preSessions,
        postSessions: postSessions ?? this.postSessions,
        errorMessage: errorMessage,
      );
}
