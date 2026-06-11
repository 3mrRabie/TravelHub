import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/core/utils/assets.dart';


class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: InkWell(
            onTap: () {
               GoRouter.of(context).pushReplacement(AppRouter.kLoginView);
            },
            child: CircleAvatar(
              radius: width * 0.05,
              backgroundColor: kWhite.withOpacity(0.3),
              child: const Icon(Icons.arrow_back, color: kText),
            ),
          ),
        ),
        SizedBox(height: height * 0.05),
       Container(
  width: width * 0.26,
  height: width * 0.26,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: loginGradient,
  ),
  child: Padding(
    padding: EdgeInsetsDirectional.all(width * 0.07),
    child: Image.asset(
      AssetsData.loginLogo,
      fit: BoxFit.contain,
    ),
  ),
)
,
        SizedBox(height: height * 0.03),
        Text(
          "Join TravelHub".tr(),
          style: TextStyle(
            fontSize: width * 0.07,
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Create your account to start exploring".tr(),
          style: TextStyle(fontSize: width * 0.04, color: Colors.white70),
        ),
      ],
    );
  }
}
