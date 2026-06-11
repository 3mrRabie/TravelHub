import 'package:flutter/material.dart';
import 'package:travel_hub/constant.dart';


class CustomPasswordField extends StatelessWidget {
  
  final IconData icon;
  final String label;
  final bool obscureText;
  final IconButton suffixIcon;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool isPasswordVisible;

  const CustomPasswordField({
    super.key,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.keyboard,
    this.validator,
    this.controller, 
    required this.isPasswordVisible, 
    required this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return TextFormField(
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        labelText: label,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.03),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBackgroundColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBackgroundColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboard,
      
    );
  }
}