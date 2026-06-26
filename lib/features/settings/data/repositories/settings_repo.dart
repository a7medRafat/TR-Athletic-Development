import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../datasources/settings_firebase_service.dart';
import '../models/user_profile_model.dart';

class SettingsRepo {
  final SettingsFirebaseService _service;

  SettingsRepo(this._service);

  String? get currentUserEmail => _service.currentUserEmail;

  Future<ApiResult<UserProfileModel?>> getProfile() async {
    try {
      final profile = await _service.getProfile();
      return ApiResult.success(profile);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<void> signOut() => _service.signOut();
}
