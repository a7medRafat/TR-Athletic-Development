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
import '../widgets/register_medical_step.dart';
import '../widgets/register_password_field_widget.dart';
import '../widgets/register_phone_field_widget.dart';

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
  final _medicalKey = GlobalKey<RegisterMedicalStepState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedGender;
  bool _genderTouched = false;
  int _step = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _genderTouched = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _selectedGender == null) return;
    setState(() => _step = 1);
  }

  void _submit(BuildContext context) {
    final medical = _medicalKey.currentState!.getMedicalHistory();
    context.read<RegisterCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      height: double.tryParse(_heightController.text.trim()),
      gender: _selectedGender,
      medicalHistory: medical.toMap(),
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
          child: Column(
            children: [
              _StepIndicator(step: _step),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _step == 0
                        ? _GeneralStep(
                            key: const ValueKey('step0'),
                            formKey: _formKey,
                            fullNameController: _fullNameController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            ageController: _ageController,
                            weightController: _weightController,
                            heightController: _heightController,
                            selectedGender: _selectedGender,
                            genderTouched: _genderTouched,
                            onGenderSelect: (g) =>
                                setState(() => _selectedGender = g),
                            onNext: _nextStep,
                            onSignIn: () => Navigator.of(context).pop(),
                          )
                        : _MedicalStep(
                            key: const ValueKey('step1'),
                            medicalKey: _medicalKey,
                            onBack: () => setState(() => _step = 0),
                            onSubmit: () => _submit(context),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StepDot(index: 0, current: step, label: AppStrings.stepGeneral),
              Expanded(
                child: Container(
                  height: 2,
                  color: step >= 1 ? AppColors.primary : AppColors.border,
                ),
              ),
              _StepDot(index: 1, current: step, label: AppStrings.stepMedical),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            step == 0 ? AppStrings.step1Title : AppStrings.step2Title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;

  const _StepDot({
    required this.index,
    required this.current,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = current > index;
    final isActive = current == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    size: 14.sp,
                    color: AppColors.surface,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isActive
                          ? AppColors.surface
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isActive || isDone
                ? AppColors.primary
                : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Step 1: General data ──────────────────────────────────────────────────────

class _GeneralStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final String? selectedGender;
  final bool genderTouched;
  final ValueChanged<String> onGenderSelect;
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  const _GeneralStep({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.ageController,
    required this.weightController,
    required this.heightController,
    required this.selectedGender,
    required this.genderTouched,
    required this.onGenderSelect,
    required this.onNext,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          RegisterFullNameFieldWidget(controller: fullNameController),
          SizedBox(height: 16.h),
          RegisterPhoneFieldWidget(controller: phoneController),
          SizedBox(height: 16.h),
          _AgeField(controller: ageController),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _DecimalField(
                  controller: weightController,
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
                  controller: heightController,
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
          _GenderSelector(
            selected: selectedGender,
            touched: genderTouched,
            onSelect: onGenderSelect,
          ),
          SizedBox(height: 16.h),
          RegisterEmailFieldWidget(controller: emailController),
          SizedBox(height: 16.h),
          RegisterPasswordFieldWidget(
            controller: passwordController,
            onSubmit: onNext,
          ),
          SizedBox(height: 32.h),
          BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) => FilledButton(
              onPressed: state.isLoading ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.next,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, size: 18.sp),
                ],
              ),
            ),
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
                onTap: onSignIn,
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
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ── Step 2: Medical history ───────────────────────────────────────────────────

class _MedicalStep extends StatelessWidget {
  final GlobalKey<RegisterMedicalStepState> medicalKey;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _MedicalStep({
    super.key,
    required this.medicalKey,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RegisterMedicalStep(key: medicalKey),
        SizedBox(height: 32.h),
        BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) => Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        AppStrings.back,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: state.isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: state.isLoading
                      ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.register,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
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
            // SizedBox(width: 8.w),
            // _GenderOption(
            //   label: AppStrings.otherGender,
            //   icon: Icons.person_outline_rounded,
            //   value: 'other',
            //   selected: selected,
            //   onSelect: onSelect,
            // ),
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
