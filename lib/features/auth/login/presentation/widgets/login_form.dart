import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/services/auth_services.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/features/auth/login/presentation/widgets/custom_password_field.dart';
import 'package:travel_hub/features/auth/login/services/login_with_google.dart';
import 'custom_text_field.dart';
import 'sign_up_text.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final key = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authService = AuthService();

    try {
      final user = await authService.loginUser(email, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? 'User');
        await prefs.setString('userUID', user.uid);

        GoRouter.of(context).pushReplacement(AppRouter.kNavigationView);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: width * 0.07,
        vertical: height * 0.03,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Form(
        key: key,
        child: Column(
          children: [
            CustomTextField(
              icon: Icons.email_outlined,
              label: "Email Address".tr(),
              controller: email,
              keyboard: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email".tr();
                }
                if (!value.contains("@")) {
                  return "Please enter a valid email".tr();
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.02),
            CustomPasswordField(
              icon: Icons.lock_outline,
              label: "Password".tr(),
              obscureText: !isPasswordVisible,
              isPasswordVisible: isPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  isPasswordVisible = !isPasswordVisible;
                  setState(() {});
                },
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              controller: password,
              keyboard: TextInputType.visiblePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password".tr();
                }
                if (value.length < 5) {
                  return "Please enter a strong password".tr();
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: InkWell(onTap: () {
                  GoRouter.of(context).pushReplacement(AppRouter.kForgetView);
                },
                child: Text(
                  "Forgot Password?".tr(),
                  style: TextStyle(color: kBackgroundColor),
                ),
              ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: height * 0.065,
              child: ElevatedButton(
                onPressed: () {
                  if (key.currentState!.validate()) {
                    signIn(context, email.text.trim(), password.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPriceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                ),
                child: Text(
                  "Sign In".tr(),
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: kWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text("or".tr(), style: TextStyle(color: kBlack)),
            SizedBox(height: height * 0.02),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _GoogleSignInButton(
                borderRadius: width * 0.03,
                onPressed: () async {
                  setState(() => isLoading = true);
                  final user = await signInWithGoogle();
                  if (mounted) setState(() => isLoading = false);
                  if (user != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userEmail', user.email ?? '');
                    await prefs.setString('userName', user.displayName ?? 'User');
                    await prefs.setString('profileImage', user.photoURL ?? '');
                    GoRouter.of(context).pushReplacement(AppRouter.kNavigationView);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Google sign-in failed")),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: height * 0.015),
            const SignUpText(),
          ],
        ),
      ),
    );
  }
}

/// A drop-in replacement for SignInButton(Buttons.Google) that does not depend
/// on flutter_signin_button or font_awesome_flutter.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double borderRadius;

  const _GoogleSignInButton({
    required this.onPressed,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFDADADA)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _GoogleLogo(size: 22),
          const SizedBox(width: 12),
          const Text(
            'Sign in with Google',
            style: TextStyle(
              color: Color(0xFF3C4043),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a Google-coloured "G" using a CustomPainter – no image assets needed.
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;

    // Blue (right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        -0.52, 1.57, false, paint);
    // Red (top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        -2.09, 1.57, false, paint);
    // Yellow (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        2.62, 1.05, false, paint);
    // Green (bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        1.67, 0.95, false, paint);

    // Horizontal bar of the "G"
    paint
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.20;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.78, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
