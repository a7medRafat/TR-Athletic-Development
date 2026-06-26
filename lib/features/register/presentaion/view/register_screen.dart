import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tr_atheletic_development/core/widgets/app_text_filed.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_strings.dart';
import '../logic/register_cubit.dart';
import '../logic/register_state.dart';
import '../widgets/register_email_field_widget.dart';
import '../widgets/register_full_name_field_widget.dart';
import '../widgets/register_password_field_widget.dart';
import '../widgets/register_phone_field_widget.dart';
import '../widgets/register_submit_button_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _previousInjuriesController = TextEditingController();

  String? _selectedGender;
  bool _genderTouched = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _previousInjuriesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _genderTouched = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _selectedGender == null) return;

    context.read<RegisterCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      height: double.tryParse(_heightController.text.trim()),
      gender: _selectedGender,
      previousInjuries: _previousInjuriesController.text.trim().isEmpty
          ? null
          : _previousInjuriesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pop();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    RegisterFullNameFieldWidget(
                      controller: _fullNameController,
                    ),
                    SizedBox(height: 16.h),
                    RegisterPhoneFieldWidget(controller: _phoneController),
                    SizedBox(height: 16.h),

                    // Age
                    _AgeField(controller: _ageController),
                    SizedBox(height: 16.h),

                    // Weight + Height
                    Row(
                      children: [
                        Expanded(
                          child: _DecimalField(
                            controller: _weightController,
                            label: AppStrings.weightKg,
                            hint: AppStrings.weightHint,
                            icon: Icons.monitor_weight_outlined,
                            emptyError: AppStrings.weightRequired,
                            invalidError: AppStrings.invalidWeight,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _DecimalField(
                            controller: _heightController,
                            label: AppStrings.heightCm,
                            hint: AppStrings.heightHint,
                            icon: Icons.straighten_rounded,
                            emptyError: AppStrings.heightRequired,
                            invalidError: AppStrings.invalidHeight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Gender selector
                    _GenderSelector(
                      selected: _selectedGender,
                      touched: _genderTouched,
                      onSelect: (g) => setState(() => _selectedGender = g),
                    ),
                    SizedBox(height: 16.h),

                    // Previous injuries (optional)
                    AppNewTextFormField(
                      controller: _previousInjuriesController,
                      inputType: InputType.text,
                      textInputAction: TextInputAction.next,
                      labelName: AppStrings.previousInjuries,
                      hintText: AppStrings.previousInjuriesHint,
                      maxLines: 2,
                      validator: (_) => null,
                    ),
                    SizedBox(height: 16.h),

                    RegisterEmailFieldWidget(controller: _emailController),
                    SizedBox(height: 16.h),
                    RegisterPasswordFieldWidget(
                      controller: _passwordController,
                      onSubmit: () => _submit(context),
                    ),
                    SizedBox(height: 32.h),
                    RegisterSubmitButtonWidget(
                      onPressed: () => _submit(context),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            AppStrings.signIn,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Age field ─────────────────────────────────────────────────────────────────

class _AgeField extends StatelessWidget {
  final TextEditingController controller;

  const _AgeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      controller: controller,
      inputType: InputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      labelName: AppStrings.age,
      hintText: AppStrings.ageHint,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return AppStrings.ageRequired;
        final n = int.tryParse(v.trim());
        if (n == null || n < 1 || n > 120) return AppStrings.invalidAge;
        return null;
      },
    );
  }
}

class _DecimalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String emptyError;
  final String invalidError;

  const _DecimalField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.emptyError,
    required this.invalidError,
  });

  @override
  Widget build(BuildContext context) {
    return AppNewTextFormField(
      controller: controller,
      labelName: label,
      inputType: InputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return emptyError;
        final n = double.tryParse(v.trim());
        if (n == null || n <= 0) return invalidError;
        return null;
      },
      hintText: hint,
    );
  }
}

// ── Gender selector ───────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final String? selected;
  final bool touched;
  final void Function(String) onSelect;

  const _GenderSelector({
    required this.selected,
    required this.touched,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = touched && selected == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
          child: Text(
            AppStrings.gender,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
        Row(
          children: [
            _GenderOption(
              label: AppStrings.male,
              icon: Icons.male_rounded,
              value: 'male',
              selected: selected,
              onSelect: onSelect,
            ),
            SizedBox(width: 8.w),
            _GenderOption(
              label: AppStrings.female,
              icon: Icons.female_rounded,
              value: 'female',
              selected: selected,
              onSelect: onSelect,
            ),
            SizedBox(width: 8.w),
            _GenderOption(
              label: AppStrings.otherGender,
              icon: Icons.person_outline_rounded,
              value: 'other',
              selected: selected,
              onSelect: onSelect,
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              AppStrings.genderRequired,
              style: TextStyle(fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String? selected;
  final void Function(String) onSelect;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
