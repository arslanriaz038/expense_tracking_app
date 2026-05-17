import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyInputField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final String? errorText;
  final TextStyle? textStyle;
  final int? maxLine;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  final bool? enable;
  final bool isPassword;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;

  const MyInputField({
    super.key,
    this.maxLine,
    required this.hintText,
    this.textStyle,
    this.keyboardType,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.enable,
    this.minLines,
    this.maxLines,
    this.labelText = '',
    this.isPassword = false,
    this.validator,
    this.errorText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
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
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        errorText: widget.errorText,
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
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
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorName.osloGray,
        ),
        labelStyle: const TextStyle(
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
