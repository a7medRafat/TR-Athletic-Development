import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_text_filed.dart';

class RegisterPasswordFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const RegisterPasswordFieldWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      inputType: InputType.password,
      labelName: AppStrings.password,
      hintText: AppStrings.passwordHint,
      controller: controller,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline),
      onFieldSubmitted: (_) => onSubmit(),
      validator: (value) {
        if (value == null || value.isEmpty) return AppStrings.passwordRequired;
        if (value.length < 6) return AppStrings.passwordTooShort;
        return null;
      },
    );
  }
}
