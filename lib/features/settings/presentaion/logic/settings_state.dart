import 'package:equatable/equatable.dart';

import '../../data/models/user_profile_model.dart';

class SettingsState extends Equatable {
  final UserProfileModel? profile;
  final String? email;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.profile,
    this.email,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    UserProfileModel? profile,
    String? email,
    bool? isLoading,
    String? errorMessage,
    bool? clearError,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError == true ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [profile, email, isLoading, errorMessage];
}
