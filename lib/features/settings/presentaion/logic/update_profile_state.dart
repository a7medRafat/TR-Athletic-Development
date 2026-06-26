import 'package:equatable/equatable.dart';

class UpdateProfileState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const UpdateProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  UpdateProfileState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool? clearError,
  }) {
    return UpdateProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage:
          clearError == true ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}
