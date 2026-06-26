import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/register_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _repo;

  RegisterCubit(this._repo) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? previousInjuries,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repo.register(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      previousInjuries: previousInjuries,
    );
    result.when(
      success: (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      failure: (error) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.message ?? 'Registration failed',
        ),
      ),
    );
  }
}
