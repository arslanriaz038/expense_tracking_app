import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:flutter/material.dart';

class MyInputField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final String? errorText;
  final TextStyle? textStyle;
  final int? maxLine;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  final bool? enable;
  final bool isPassword;
  final int? minLines;
  final int? maxLines;

  const MyInputField({
    super.key,
    this.maxLine,
    required this.hintText,
    this.textStyle,
    this.keyboardType,
    this.suffixIcon,
    this.controller,
    this.enable,
    this.minLines,
    this.maxLines,
    this.labelText = '',
    this.isPassword = false,
    this.validator,
    this.errorText,
  });

  @override
  State<MyInputField> createState() => _MyInputFieldState();
}

class _MyInputFieldState extends State<MyInputField> {
  bool _obscureText = true;

  void _changeTextVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enable,
      obscureText: widget.isPassword && _obscureText,
      controller: widget.controller,
      validator: widget.validator,
      style: widget.textStyle ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        errorText: widget.errorText,
        suffixIcon: widget.isPassword
            ? IconButton(
                splashRadius: 1,
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: ColorName.primaryColor,
                ),
                onPressed: _changeTextVisibility,
              )
            : widget.suffixIcon,

        labelText: widget.hintText,
        hintText: widget.hintText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: ColorName.primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: ColorName.mercury),
        ),
        focusColor: ColorName.primaryColor,
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorName.osloGray,
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ColorName.gray,
        ),
        // floatingLabelStyle: TextStyle(
        //   fontSize: 16.sp,
        //   fontWeight: FontWeight.w400,
        //   color: AppColors.mediumRedViolet,
        // ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(
            color: ColorName.textFieldBorder,
          ),
        ),
        fillColor: ColorName.snow,
        filled: true,
      ),
    );
  }
}
