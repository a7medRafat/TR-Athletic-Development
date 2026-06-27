import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repositories/admin_repo.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminRepo _repo;
  StreamSubscription<List<AdminUserModel>>? _sub;

  AdminUsersCubit(this._repo) : super(const AdminUsersState()) {
    _listenUsers();
  }

  void _listenUsers() {
    emit(state.copyWith(isLoading: true));
    _sub = _repo.streamUsers().listen(
      (users) => emit(state.copyWith(allUsers: users, isLoading: false)),
      onError: (e) => emit(
        state.copyWith(isLoading: false, errorMessage: e.toString()),
      ),
    );
  }

  void setFilter(String filter) => emit(state.copyWith(statusFilter: filter));
  void setReadinessFilter(String filter) =>
      emit(state.copyWith(readinessFilter: filter));

  // Unified single-row filter: all | ready | not_ready | pending | disabled
  void setUnifiedFilter(String filter) {
    switch (filter) {
      case 'ready':
        emit(state.copyWith(
            unifiedFilter: filter,
            statusFilter: 'approved',
            readinessFilter: 'ready'));
      case 'not_ready':
        emit(state.copyWith(
            unifiedFilter: filter,
            statusFilter: 'approved',
            readinessFilter: 'not_ready'));
      case 'pending':
        emit(state.copyWith(
            unifiedFilter: filter,
            statusFilter: 'pending',
            readinessFilter: 'all'));
      case 'disabled':
        emit(state.copyWith(
            unifiedFilter: filter,
            statusFilter: 'disabled',
            readinessFilter: 'all'));
      default:
        emit(state.copyWith(
            unifiedFilter: 'all',
            statusFilter: 'all',
            readinessFilter: 'all'));
    }
  }
  void setSearch(String q) => emit(state.copyWith(searchQuery: q));

  Future<void> approveUser(String uid) async {
    emit(state.copyWith(clearMessages: true));
    final result = await _repo.approveUser(uid);
    result.when(
      success: (_) => emit(state.copyWith(successMessage: 'User approved successfully')),
      failure: (e) => emit(state.copyWith(errorMessage: e.message ?? 'Failed to approve')),
    );
  }

  Future<void> rejectUser(String uid, {String? reason}) async {
    emit(state.copyWith(clearMessages: true));
    final result = await _repo.rejectUser(uid, reason: reason);
    result.when(
      success: (_) => emit(state.copyWith(successMessage: 'User rejected')),
      failure: (e) => emit(state.copyWith(errorMessage: e.message ?? 'Failed to reject')),
    );
  }

  Future<void> setUserStatus(String uid, String status) async {
    emit(state.copyWith(clearMessages: true));
    final result = await _repo.setUserStatus(uid, status);
    final msg = status == 'disabled' ? 'User account disabled' : 'User account enabled';
    result.when(
      success: (_) => emit(state.copyWith(successMessage: msg)),
      failure: (e) => emit(state.copyWith(errorMessage: e.message ?? 'Failed to update')),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
