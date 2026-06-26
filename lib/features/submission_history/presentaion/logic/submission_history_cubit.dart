import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/post_training/data/repositories/post_training_repo.dart';
import '../../../../features/pre_training/data/repositories/pre_training_repo.dart';
import 'submission_history_state.dart';

class SubmissionHistoryCubit extends Cubit<SubmissionHistoryState> {
  final PreTrainingRepo _preRepo;
  final PostTrainingRepo _postRepo;

  SubmissionHistoryCubit(this._preRepo, this._postRepo)
      : super(const SubmissionHistoryState());

  Future<void> load(String uid) async {
    emit(state.copyWith(isLoading: true));

    final preResult = await _preRepo.fetchByUid(uid);
    final postResult = await _postRepo.fetchByUid(uid);

    emit(
      state.copyWith(
        isLoading: false,
        preSessions: preResult.when(
          success: (data) => data,
          failure: (_) => [],
        ),
        postSessions: postResult.when(
          success: (data) => data,
          failure: (_) => [],
        ),
        errorMessage: preResult.when(
          success: (_) => null,
          failure: (e) => e.message,
        ),
      ),
    );
  }
}
