import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../post_training/data/repositories/post_training_repo.dart';
import '../../../pre_training/data/repositories/pre_training_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PreTrainingRepo _preRepo;
  final PostTrainingRepo _postRepo;

  HomeCubit(this._preRepo, this._postRepo) : super(const HomeState()) {
    checkToday();
  }

  Future<void> checkToday() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _preRepo.hasSubmittedToday(uid),
      _postRepo.hasSubmittedToday(uid),
    ]);

    bool hasPreToday = state.hasPreToday;
    bool hasPostToday = state.hasPostToday;

    results[0].when(
      success: (val) => hasPreToday = val,
      failure: (_) {},
    );
    results[1].when(
      success: (val) => hasPostToday = val,
      failure: (_) {},
    );

    emit(state.copyWith(
      isLoading: false,
      hasPreToday: hasPreToday,
      hasPostToday: hasPostToday,
    ));
  }
}
