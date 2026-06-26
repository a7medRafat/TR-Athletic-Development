import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../../data/models/user_profile_model.dart';
import '../logic/update_profile_cubit.dart';
import '../logic/update_profile_state.dart';
import '../widgets/update_profile_full_name_field_widget.dart';
import '../widgets/update_profile_header_widget.dart';
import '../widgets/update_profile_phone_field_widget.dart';
import '../widgets/update_profile_submit_button_widget.dart';

class UpdateProfileScreen extends StatelessWidget {
  final UserProfileModel? profile;

  const UpdateProfileScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UpdateProfileCubit>(),
      child: _UpdateProfileView(profile: profile),
    );
  }
}

class _UpdateProfileView extends StatefulWidget {
  final UserProfileModel? profile;

  const _UpdateProfileView({this.profile});

  @override
  State<_UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<_UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;

  bool get _hasChanges =>
      _fullNameController.text.trim() != (widget.profile?.fullName ?? '') ||
      _phoneController.text.trim() != (widget.profile?.phoneNumber ?? '');

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.profile?.fullName ?? '');
    _phoneController =
        TextEditingController(text: widget.profile?.phoneNumber ?? '');
    _fullNameController.addListener(_refresh);
    _phoneController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _fullNameController.removeListener(_refresh);
    _phoneController.removeListener(_refresh);
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<UpdateProfileCubit>().update(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<UpdateProfileCubit, UpdateProfileState>(
        listener: (context, state) {
          if (state.isSuccess) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.profileUpdated),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state.errorMessage != null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
          }
        },
        child: Column(
          children: [
            UpdateProfileHeaderWidget(profile: widget.profile),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileFormCard(
                        fullNameController: _fullNameController,
                        phoneController: _phoneController,
                        onSubmit: () => _submit(context),
                      ),
                      SizedBox(height: 24.h),
                      UpdateProfileSubmitButtonWidget(
                        hasChanges: _hasChanges,
                        onPressed: () => _submit(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final VoidCallback onSubmit;

  const _ProfileFormCard({
    required this.fullNameController,
    required this.phoneController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                AppStrings.personalInformation,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          UpdateProfileFullNameFieldWidget(controller: fullNameController),
          SizedBox(height: 16.h),
          UpdateProfilePhoneFieldWidget(
            controller: phoneController,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}
