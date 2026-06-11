import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/features/welcome/future_item.dart';

class TravelWelcomeScreen extends StatelessWidget {
  const TravelWelcomeScreen({super.key});

  void changeLanguage(BuildContext context) {
    if (context.locale == const Locale('en')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => changeLanguage(context),
            icon: const Icon(Icons.language),
            color: Colors.white,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(gradient: loginGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.025),
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flight_takeoff,
                    size: width * 0.12,
                    color: kWhite,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  'TravelHub'.tr(),
                  style: TextStyle(
                    color: kWhite,
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Discover. Explore. Experience.'.tr(),
                  style: TextStyle(
                    color: kWhite,
                    fontSize: width * 0.04,
                  ),
                ),
                SizedBox(height: height * 0.045),
                 FeatureItem(
                  icon: Icons.location_on,
                  title: 'Discover Amazing Places'.tr(),
                  description:
                      'Find hidden gems and popular destinations worldwide'.tr(),
                ),
                SizedBox(height: height * 0.025),
                 FeatureItem(
                  icon: Icons.camera_alt,
                  title: 'AI-Powered Recognition'.tr(),
                  description:
                      'Identify landmarks instantly with our smart camera'.tr(),
                ),
                SizedBox(height: height * 0.025),
                 FeatureItem(
                  icon: Icons.person,
                  title: 'Personalized Experience'.tr(),
                  description:
                      'Get recommendations tailored to your preferences'.tr(),
                ),
                const Spacer(),
                Text(
                  'Ready to start your journey?'.tr(),
                  style: TextStyle(
                    color: kWhite,
                    fontSize: width * 0.04,
                  ),
                ),
                SizedBox(height: height * 0.006),
                Text(
                  'Join millions of travelers exploring the world with TravelHub'.tr(),
                  style: TextStyle(
                    color: kWhite,
                    fontSize: width * 0.035,
                  ),
                ),
                SizedBox(height: height * 0.03),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context)
                        .pushReplacement(AppRouter.kLoginView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPriceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.25,
                      vertical: height * 0.018,
                    ),
                  ),
                  child: Text(
                    "Get Started".tr(),
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: kWhite,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
