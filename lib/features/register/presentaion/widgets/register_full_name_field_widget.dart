import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_text_filed.dart';

class RegisterFullNameFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const RegisterFullNameFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      inputType: InputType.name,
      labelName: AppStrings.fullName,
      hintText: AppStrings.fullNameHint,
      controller: controller,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.person_outline),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return AppStrings.fullNameRequired;
        return null;
      },
    );
  }
}
