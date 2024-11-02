import 'package:flutter/material.dart';
import '../main.dart';

class RoundedTextField extends StatelessWidget {
  final double width;
  final double height;
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final EdgeInsetsGeometry? padding;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const RoundedTextField({
    Key? key,
    required this.width,
    required this.height,
    required this.controller,
    this.hintText,
    this.labelText,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.padding,
    this.obscureText = false,
    this.keyboardType,
    this.textStyle,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mq.width *.03),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        cursorColor: Colors.greenAccent,
        style: textStyle ?? TextStyle(color: textColor ?? Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(color: hintColor ?? Colors.grey, fontSize: mq.width *.037),
          labelStyle: TextStyle(color: Colors.white, fontSize: mq.width * .04),
          fillColor: fillColor ?? Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(mq.width *.08),
            borderSide: BorderSide(color: borderColor ?? Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(mq.width *.08),
            borderSide: BorderSide(color: borderColor ?? Colors.blueAccent),
          ),
          contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }
}
