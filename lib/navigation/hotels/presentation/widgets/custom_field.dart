import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

class CustomField extends StatelessWidget {
  final String title;
  final double width;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final TextInputType? keyboard;

  const CustomField({
    super.key,
    required this.title,
    required this.width,
    this.hint,
    this.icon,
    required this.controller,
    required this.validator,
    this.onTap,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          // kBlack was hardcoded — labels were always black even in dark mode.
          // Theme.of(context).textTheme.bodyLarge?.color is white in dark, black in light.
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14.r,
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.r, horizontal: 4.r),
          child: TextFormField(
            controller: controller,
            validator: validator,
            cursorColor: kGrey,

            cursorWidth: 1.5.w,
            onTap: onTap,
            keyboardType: keyboard,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: kAssets),
              ),
            
              prefixIcon: icon != null
                  ? Icon(icon, color: kAssets, size: 24.r)
                  : null,
              hintText: hint,
              hintStyle: TextStyle(color: kAssets),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              contentPadding: icon == null
                  ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h)
                  : null, 
            ),
          ),
        ),
      ],
    );
  }
}
