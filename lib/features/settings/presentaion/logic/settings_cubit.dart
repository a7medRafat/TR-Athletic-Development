import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/settings_repo.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepo _repo;

  SettingsCubit(this._repo) : super(const SettingsState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final email = _repo.currentUserEmail;
    final result = await _repo.getProfile();
    result.when(
      success: (profile) => emit(
        state.copyWith(isLoading: false, profile: profile, email: email),
      ),
      failure: (error) => emit(
        state.copyWith(
          isLoading: false,
          email: email,
          errorMessage: error.message ?? 'Failed to load profile',
        ),
      ),
    );
  }

  Future<void> signOut() => _repo.signOut();
}
