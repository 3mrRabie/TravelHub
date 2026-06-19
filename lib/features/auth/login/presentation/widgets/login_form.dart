import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final authService = AuthService();
    // Capture messenger and router before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final user = await authService.loginUser(
        email.text.trim(),
        password.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? 'User');
        await prefs.setString('userUID', user.uid);
        if (mounted) router.pushReplacement(AppRouter.kNavigationView);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (isGoogleLoading) return; // Prevent duplicate requests.

    setState(() => isGoogleLoading = true);
    // Capture messenger and router before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final user = await signInWithGoogle();
      if (!mounted) return;

      if (user != null) {
        // Persist session data for offline/warm-start reads.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? 'User');
        await prefs.setString('userUID', user.uid);
        await prefs.setString('profileImage', user.photoURL ?? '');
        if (mounted) router.pushReplacement(AppRouter.kNavigationView);
      }
      // user == null means the user cancelled – no error message needed.
    } on GoogleSignInException catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('google_signin_failed'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
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
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              icon: Icons.email_outlined,
              label: 'Email Address'.tr(),
              controller: email,
              keyboard: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email'.tr();
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.02),
            CustomPasswordField(
              icon: Icons.lock_outline,
              label: 'Password'.tr(),
              obscureText: !isPasswordVisible,
              isPasswordVisible: isPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                },
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              controller: password,
              keyboard: TextInputType.visiblePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password'.tr();
                }
                if (value.length < 5) {
                  return 'Please enter a strong password'.tr();
                }
                return null;
              },
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  GoRouter.of(context).pushReplacement(AppRouter.kForgetView);
                },
                child: Text(
                  'Forgot Password?'.tr(),
                  style: const TextStyle(color: kBackgroundColor),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: height * 0.065,
              child: ElevatedButton(
                onPressed: isLoading ? null : _signInWithEmailPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPriceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: kWhite,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Sign In'.tr(),
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: kWhite,
                        ),
                      ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text('or'.tr(), style: const TextStyle(color: kBlack)),
            SizedBox(height: height * 0.02),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _GoogleSignInButton(
                borderRadius: width * 0.03,
                isLoading: isGoogleLoading,
                onPressed: isGoogleLoading ? null : _signInWithGoogle,
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

// ─── Google Sign-In Button ────────────────────────────────────────────────────

/// Google-branded sign-in button that follows the official branding guidelines:
/// https://developers.google.com/identity/branding-guidelines
///
/// Uses the official Google "G" logo SVG asset (assets/icons/google_logo.svg).
/// The asset contains the exact path data published by Google – it is NOT
/// generated or approximated in code.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double borderRadius;
  final bool isLoading;

  const _GoogleSignInButton({
    required this.onPressed,
    this.borderRadius = 8,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sign in with Google',
      button: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDADADA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Google "G" logo – loaded from the SVG asset.
                  // Source: https://developers.google.com/identity/branding-guidelines
                  // The SVG path data is exactly as published by Google.
                  SvgPicture.asset(
                    'assets/icons/google_logo.svg',
                    width: 22,
                    height: 22,
                    semanticsLabel: 'Google logo',
                  ),
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
      ),
    );
  }
}
