import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../features/pre_training/data/models/pre_training_model.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../datasources/admin_firebase_service.dart';
import '../models/admin_user_model.dart';

class AdminRepo {
  final AdminFirebaseService _service;

  AdminRepo(this._service);

  Stream<List<AdminUserModel>> streamUsers({String? statusFilter}) =>
      _service.streamUsers(statusFilter: statusFilter);

  Future<ApiResult<void>> approveUser(String uid) async {
    try {
      await _service.approveUser(uid);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> rejectUser(String uid, {String? reason}) async {
    try {
      await _service.rejectUser(uid, reason: reason);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> setUserStatus(String uid, String status) async {
    try {
      await _service.setUserStatus(uid, status);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<AdminUserModel?>> getUser(String uid) async {
    try {
      final user = await _service.getUser(uid);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<PreTrainingModel>>> getPreTrainingSessions(
      String uid) async {
    try {
      final list = await _service.getPreTrainingSessions(uid);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<PostTrainingModel>>> getPostTrainingSessions(
      String uid) async {
    try {
      final list = await _service.getPostTrainingSessions(uid);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updatePreTrainingSession(
      PreTrainingModel session) async {
    try {
      await _service.updatePreTrainingSession(session);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deletePreTrainingSession(
      String uid, String docId) async {
    try {
      await _service.deletePreTrainingSession(uid, docId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteUserCompletely(String uid) async {
    try {
      await _service.deleteUserCompletely(uid);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updatePostTrainingSession(
      PostTrainingModel session) async {
    try {
      await _service.updatePostTrainingSession(session);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deletePostTrainingSession(String docId) async {
    try {
      await _service.deletePostTrainingSession(docId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}
