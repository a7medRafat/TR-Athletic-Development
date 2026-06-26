import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const RegisterState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool? clearError,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage:
          clearError == true ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}
