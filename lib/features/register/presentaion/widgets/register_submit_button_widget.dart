import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_strings.dart';
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
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(AppStrings.register),
        );
      },
    );
  }
}
