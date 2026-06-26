import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_text_filed.dart';

class RegisterEmailFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const RegisterEmailFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      inputType: InputType.email,
      labelName: AppStrings.email,
      hintText: AppStrings.emailHint,
      controller: controller,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return AppStrings.emailRequired;
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return AppStrings.invalidEmail;
        }
        return null;
      },
    );
  }
}
