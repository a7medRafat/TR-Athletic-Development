import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../datasources/register_firebase_service.dart';

class RegisterRepo {
  final RegisterFirebaseService _service;

  RegisterRepo(this._service);

  Future<ApiResult<String>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    int? age,
    double? weight,
    double? height,
    String? gender,
  }) async {
    try {
      final uid = await _service.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        age: age,
        weight: weight,
        height: height,
        gender: gender,
      );
      return ApiResult.success(uid);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}
