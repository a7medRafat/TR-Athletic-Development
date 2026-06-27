import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../datasources/pre_training_firebase_service.dart';
import '../models/pre_training_model.dart';

class PreTrainingRepo {
  final PreTrainingFirebaseService _service;

  PreTrainingRepo(this._service);

  Future<ApiResult<String>> submit(PreTrainingModel model) async {
    try {
      final id = await _service.submit(model);
      return ApiResult.success(id);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<bool>> hasSubmittedToday(String uid) async {
    try {
      final result = await _service.hasSubmittedToday(uid);
      return ApiResult.success(result);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<List<PreTrainingModel>>> fetchByUid(String uid) async {
    try {
      final list = await _service.fetchByUid(uid);
      return ApiResult.success(list);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
