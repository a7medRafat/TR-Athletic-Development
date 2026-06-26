import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../datasources/update_profile_firebase_service.dart';

class UpdateProfileRepo {
  final UpdateProfileFirebaseService _service;

  UpdateProfileRepo(this._service);

  Future<ApiResult<String>> update({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await _service.update(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      return const ApiResult.success('');
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}
