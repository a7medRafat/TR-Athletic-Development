import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../datasources/login_firebase_service.dart';

class LoginRepo {
  final LoginFirebaseService _service;

  LoginRepo(this._service);

  Future<ApiResult<UserCredential>> signIn(
    String email,
    String password,
  ) async {
    try {
      final result = await _service.signInWithEmailAndPassword(email, password);
      return ApiResult.success(result);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<void>> signOut() async {
    try {
      await _service.signOut();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
