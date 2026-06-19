import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/features/auth/login/services/login_with_google.dart';

import '../../login/presentation/widgets/custom_text_field.dart';
import '../../login/presentation/widgets/sign_in_text.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  bool loading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _setLoading(bool v) async {
    if (!mounted) return;
    setState(() => loading = v);
  }

  Future<void> signUp(BuildContext context) async {
    if (loading) return;

    // Capture context-dependent objects before any await gap.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    await _setLoading(true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': name.text.trim(),
            'email': email.text.trim(),
            'phone': phone.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (name.text.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(name.text.trim());
        await cred.user?.reload();
      }

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Account created successfully!'.tr())),
      );
      router.pushReplacement(AppRouter.kLoginView);
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.'.tr();
      } else if (e.code == 'weak-password') {
        message = 'Your password is too weak.'.tr();
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email.'.tr();
      } else {
        message = 'Registration failed. Please try again.'.tr();
      }
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (isGoogleLoading) return; // Prevent duplicate requests.

    // Capture context-dependent objects before the first await.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => isGoogleLoading = true);
    try {
      final user = await signInWithGoogle();
      if (!mounted) return;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? 'User');
        await prefs.setString('userUID', user.uid);
        await prefs.setString('profileImage', user.photoURL ?? '');
        if (mounted) router.pushReplacement(AppRouter.kNavigationView);
      }
      // user == null means the user cancelled – no snackbar needed.
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

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: width * 0.05,
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
                icon: Icons.person,
                label: 'Full Name'.tr(),
                controller: name,
                keyboard: TextInputType.name,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your full name'.tr()
                    : null,
              ),
              SizedBox(height: height * 0.02),
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
              CustomTextField(
                icon: Icons.phone_android_outlined,
                label: 'Phone'.tr(),
                controller: phone,
                keyboard: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number'.tr();
                  }
                  if (!RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
                    return 'Please enter a valid Egyptian phone number'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.02),
              CustomTextField(
                icon: Icons.lock_outline,
                label: 'Password'.tr(),
                obscureText: true,
                suffixIcon: Icons.visibility_off_outlined,
                controller: password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password'.tr();
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.02),
              CustomTextField(
                icon: Icons.lock_outline,
                label: 'Confirm Password'.tr(),
                obscureText: true,
                suffixIcon: Icons.visibility_off_outlined,
                controller: confirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password'.tr();
                  }
                  if (value != password.text) {
                    return "Passwords don't match".tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.05),

              SizedBox(
                width: double.infinity,
                height: height * 0.065,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (key.currentState!.validate()) {
                            signUp(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPriceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create Account'.tr(),
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

              const SignInText(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────

/// Google-branded sign-in button following the official branding guidelines:
/// https://developers.google.com/identity/branding-guidelines
///
/// Uses the official Google "G" logo SVG asset (assets/icons/google_logo.svg).
/// The SVG contains the exact path data published by Google — NOT generated
/// or approximated in code.
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
