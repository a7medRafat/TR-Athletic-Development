import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../logic/register_cubit.dart';
import '../logic/register_state.dart';

class RegisterSubmitButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterSubmitButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        return AppSubmitButton(
          label: AppStrings.register,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
        );
      },
    );
  }
}
