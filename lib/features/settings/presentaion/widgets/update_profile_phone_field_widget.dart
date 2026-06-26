import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_text_filed.dart';

class UpdateProfilePhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const UpdateProfilePhoneFieldWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      inputType: InputType.phone,
      labelName: AppStrings.phoneNumber,
      hintText: AppStrings.phoneHint,
      controller: controller,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.phone_outlined),
      onFieldSubmitted: (_) => onSubmit(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return AppStrings.phoneRequired;
        return null;
      },
    );
  }
}
