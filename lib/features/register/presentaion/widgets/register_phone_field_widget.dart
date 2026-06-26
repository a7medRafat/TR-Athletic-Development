import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_text_filed.dart';

class RegisterPhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const RegisterPhoneFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      inputType: InputType.phone,
      labelName: AppStrings.phoneNumber,
      hintText: AppStrings.phoneHint,
      controller: controller,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.phone_outlined),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return AppStrings.phoneRequired;
        return null;
      },
    );
  }
}
