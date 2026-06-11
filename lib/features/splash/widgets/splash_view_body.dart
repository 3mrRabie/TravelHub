import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/core/utils/assets.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    Timer(const Duration(seconds: 6), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final seenWelcome = prefs.getBool('seenWelcome') ?? false;

      if (!seenWelcome) {
        await prefs.setBool('seenWelcome', true);
        if (!mounted) return;
        GoRouter.of(context).pushReplacement(AppRouter.kWelcomeView);
      } else {
        if (!mounted) return;
        GoRouter.of(context).pushReplacement(AppRouter.kLoginView);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(AssetsData.splashLogo, width: width * 0.4),
            ),
            SizedBox(height: height * 0.00001),
            Text(
              'TravelHub'.tr(),
              style: TextStyle(
                color: kWhite,
                fontSize: width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Discover the world'.tr(),
              style: TextStyle(
                color: kWhite.withOpacity(0.9),
                fontSize: width * 0.045,
              ),
            ),
            SizedBox(height: height * 0.03),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: width * 0.35 * _animation.value,
                  height: 2,
                  color: kWhite.withOpacity(0.9),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
