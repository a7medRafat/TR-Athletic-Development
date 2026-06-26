import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../logic/login_cubit.dart';
import '../logic/login_state.dart';

class LoginSubmitButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginSubmitButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return AppSubmitButton(
          label: AppStrings.login,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
        );
      },
    );
  }
}
