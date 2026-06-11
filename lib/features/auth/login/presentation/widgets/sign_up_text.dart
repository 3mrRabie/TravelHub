import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';


class SignUpText extends StatelessWidget {
  const SignUpText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?".tr(), style: TextStyle(color: kBlack)),
        GestureDetector(
          onTap: () {GoRouter.of(context).pushReplacement(AppRouter.kRegisterView);},
          child: Text(
            "Sign Up".tr(),
            style: TextStyle(
              color: kBackgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
