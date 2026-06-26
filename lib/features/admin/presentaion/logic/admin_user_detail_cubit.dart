import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repositories/admin_repo.dart';
import 'admin_user_detail_state.dart';

class AdminUserDetailCubit extends Cubit<AdminUserDetailState> {
  final AdminRepo _repo;
  final String uid;

  AdminUserDetailCubit(this._repo, {required this.uid})
      : super(const AdminUserDetailState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final userRes = await _repo.getUser(uid);
    final preRes = await _repo.getPreTrainingSessions(uid);
    final postRes = await _repo.getPostTrainingSessions(uid);

    String? error;
    userRes.when(success: (_) {}, failure: (e) => error = e.message);
    preRes.when(success: (_) {}, failure: (e) => error ??= e.message);
    postRes.when(success: (_) {}, failure: (e) => error ??= e.message);

    emit(state.copyWith(
      isLoading: false,
      user: userRes.maybeWhen(success: (u) => u, orElse: () => null),
      preSessions: preRes.maybeWhen(success: (l) => l, orElse: () => []),
      postSessions: postRes.maybeWhen(success: (l) => l, orElse: () => []),
      errorMessage: error,
    ));
  }

  Future<void> approveUser() async {
    final result = await _repo.approveUser(uid);
    result.when(
      success: (_) {
        final updated = state.user != null
            ? AdminUserModelExt.withStatus(state.user!, 'approved')
            : null;
        emit(state.copyWith(
          user: updated,
          successMessage: 'User approved successfully',
        ));
      },
      failure: (e) =>
          emit(state.copyWith(errorMessage: e.message ?? 'Failed to approve')),
    );
  }

  Future<void> rejectUser({String? reason}) async {
    final result = await _repo.rejectUser(uid, reason: reason);
    result.when(
      success: (_) {
        final updated = state.user != null
            ? AdminUserModelExt.withStatus(state.user!, 'rejected')
            : null;
        emit(state.copyWith(
          user: updated,
          successMessage: 'User rejected',
        ));
      },
      failure: (e) =>
          emit(state.copyWith(errorMessage: e.message ?? 'Failed to reject')),
    );
  }

  Future<void> setUserStatus(String status) async {
    final result = await _repo.setUserStatus(uid, status);
    final msg = status == 'disabled' ? 'User account disabled' : 'User account enabled';
    result.when(
      success: (_) {
        final updated = state.user != null
            ? AdminUserModelExt.withStatus(state.user!, status)
            : null;
        emit(state.copyWith(user: updated, successMessage: msg));
      },
      failure: (e) => emit(
        state.copyWith(errorMessage: e.message ?? 'Failed to update'),
      ),
    );
  }
}

class AdminUserModelExt {
  static AdminUserModel withStatus(AdminUserModel u, String status) =>
      AdminUserModel(
        uid: u.uid,
        email: u.email,
        fullName: u.fullName,
        phoneNumber: u.phoneNumber,
        role: u.role,
        status: status,
        createdAt: u.createdAt,
        approvedAt: u.approvedAt,
        approvedBy: u.approvedBy,
        rejectionReason: u.rejectionReason,
        disabledAt: u.disabledAt,
      );
}
