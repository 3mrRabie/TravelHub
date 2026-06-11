import 'package:flutter/material.dart';
import 'package:travel_hub/constant.dart';

/// A text field that manages its own password-visibility toggle when
/// [obscureText] is initially set to true. For non-password fields the
/// widget behaves exactly like before (pure display, no toggle).
class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool obscureText;
  /// Ignored when [obscureText] is true — the widget supplies its own toggle.
  final IconData? suffixIcon;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboard,
    this.validator,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Tracks real-time visibility. Only meaningful when widget.obscureText==true.
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText; // start hidden if caller asked for password mode
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isPasswordField = widget.obscureText;

    Widget? suffix;
    if (isPasswordField) {
      // Self-managed interactive toggle button
      suffix = IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: kBackgroundColor,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffix = Icon(widget.suffixIcon);
    }

    return TextFormField(
      obscureText: isPasswordField ? _hidden : false,
      validator: widget.validator,
      controller: widget.controller,
      keyboardType: widget.keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        suffixIcon: suffix,
        labelText: widget.label,
        hintText: widget.label,
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
    );
  }
}
