import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _repo;

  LoginCubit(this._repo) : super(const LoginInitial());

  Future<void> signIn(String email, String password) async {
    emit(const LoginLoading());

    final result = await _repo.signIn(email.trim(), password);

    result.when(
      success: (_) => emit(const LoginSuccess()),
      failure: (error) => emit(LoginFailure(error.message ?? 'Login failed')),
    );
  }
}
