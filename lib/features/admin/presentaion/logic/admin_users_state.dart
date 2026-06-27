import 'package:equatable/equatable.dart';

import '../../../../core/utils/readiness_calculator.dart';
import '../../data/models/admin_user_model.dart';

class AdminUsersState extends Equatable {
  final List<AdminUserModel> allUsers;
  final String statusFilter;
  final String readinessFilter; // 'all' | 'ready' | 'not_ready'
  final String unifiedFilter; // 'all' | 'ready' | 'not_ready' | 'pending' | 'disabled'
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AdminUsersState({
    this.allUsers = const [],
    this.statusFilter = 'all',
    this.readinessFilter = 'all',
    this.unifiedFilter = 'all',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  List<AdminUserModel> get filtered {
    var list = allUsers;
    if (statusFilter != 'all') {
      list = list.where((u) => u.status == statusFilter).toList();
    }
    if (readinessFilter != 'all') {
      list = list.where((u) {
        final score = u.lastReadinessScore;
        if (score == null) return false;
        final ready = ReadinessCalculator.isReady(score);
        return readinessFilter == 'ready' ? ready : !ready;
      }).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.phoneNumber.contains(q))
          .toList();
    }
    return list;
  }

  int get pendingCount =>
      allUsers.where((u) => u.isPending).length;

  AdminUsersState copyWith({
    List<AdminUserModel>? allUsers,
    String? statusFilter,
    String? readinessFilter,
    String? unifiedFilter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      AdminUsersState(
        allUsers: allUsers ?? this.allUsers,
        statusFilter: statusFilter ?? this.statusFilter,
        readinessFilter: readinessFilter ?? this.readinessFilter,
        unifiedFilter: unifiedFilter ?? this.unifiedFilter,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );

  @override
  List<Object?> get props => [
        allUsers,
        statusFilter,
        readinessFilter,
        unifiedFilter,
        searchQuery,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
