import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/update_profile_repo.dart';
import 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final UpdateProfileRepo _repo;

  UpdateProfileCubit(this._repo) : super(const UpdateProfileState());

  Future<void> update({
    required String fullName,
    required String phoneNumber,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repo.update(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    result.when(
      success: (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      failure: (error) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.message ?? 'Update failed',
        ),
      ),
    );
  }
}
