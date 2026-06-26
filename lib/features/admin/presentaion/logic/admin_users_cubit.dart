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
