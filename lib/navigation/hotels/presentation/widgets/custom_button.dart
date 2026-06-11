import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Function()? onPressed;
  final IconData? icon;
  final Color? buttonColor;
  final Color? textColor;
  const CustomButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.icon,
    this.buttonColor,
    this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.r, horizontal: 4.r),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(buttonColor??kBackgroundColor),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 73.w),
            Icon(icon, color: kWhite, size: 20.r),
            Text(
              buttonText,
              style: TextStyle(color: textColor??kWhite, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
