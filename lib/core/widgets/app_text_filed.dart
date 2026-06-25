import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

enum DecorationType { underlined, outlined, filled }

enum InputType {
  text,
  name,
  number,
  email,
  password,
  phone,
  url,
  price,
  search,
}

class AppNewTextFormField extends StatefulWidget {
  final EdgeInsetsGeometry? contentPadding;
  final DecorationType decorationType;
  final InputType inputType;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final String? labelName;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final Color? borderSideColor;
  final double? borderRadius;
  final double? borderSideWidth;
  final double? height;
  final TextEditingController? controller;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool? autofocus;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;

  const AppNewTextFormField({
    super.key,
    required this.hintText,
    required this.validator,
    this.readOnly = false,
    this.contentPadding,
    this.inputTextStyle,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    this.borderSideColor,
    this.borderRadius,
    this.borderSideWidth,
    this.inputFormatters,
    this.focusNode,
    this.autofocus,
    this.inputType = InputType.text,
    this.decorationType = DecorationType.outlined,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.textInputAction,
    this.labelName,
    this.height,
  });

  @override
  State<AppNewTextFormField> createState() => _AppNewTextFormFieldState();
}

class _AppNewTextFormFieldState extends State<AppNewTextFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.inputType == InputType.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelName != null) ...[
          Text(
            widget.labelName!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          textAlignVertical: TextAlignVertical.center,
          onTap: widget.onTap,
          maxLines: isPassword ? 1 : widget.maxLines,
          autofocus: widget.autofocus ?? false,
          focusNode: widget.focusNode,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          readOnly: widget.readOnly,
          controller: widget.controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          obscureText: isPassword ? _obscurePassword : false,
          style: widget.inputTextStyle ??
              TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            isDense: true,
            constraints: BoxConstraints(
              minHeight: widget.height ?? (widget.maxLines == 1 ? 52.h : 0),
            ),
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            hintStyle: widget.hintStyle ??
                TextStyle(fontSize: 13.sp, color: AppColors.textHint),
            hintText: widget.hintText,
            fillColor: widget.backgroundColor ?? AppColors.surfaceVariant,
            filled: true,
            prefixIcon: widget.prefixIcon,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : widget.suffixIcon,
          ),
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case InputType.number:
        return TextInputType.number;
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.password:
        return TextInputType.visiblePassword;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.url:
        return TextInputType.url;
      case InputType.price:
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.inputType) {
      case InputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputType.price:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
      case InputType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return widget.inputFormatters;
    }
  }
}
