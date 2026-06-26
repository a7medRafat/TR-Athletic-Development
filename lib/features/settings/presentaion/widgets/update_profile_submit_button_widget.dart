import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../logic/update_profile_cubit.dart';
import '../logic/update_profile_state.dart';

class UpdateProfileSubmitButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasChanges;

  const UpdateProfileSubmitButtonWidget({
    super.key,
    required this.onPressed,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
      builder: (context, state) {
        return AppSubmitButton(
          label: hasChanges ? AppStrings.saveChanges : AppStrings.noChanges,
          onPressed: hasChanges && !state.isLoading ? onPressed : null,
          isLoading: state.isLoading,
          icon: hasChanges ? Icons.check_rounded : null,
        );
      },
    );
  }
}
