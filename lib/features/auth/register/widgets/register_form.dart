import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

    // Capture context-dependent objects before any await gap
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
        SnackBar(content: Text("Account created successfully!".tr())),
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
                label: "Full Name".tr(),
                controller: name,
                keyboard: TextInputType.name,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter your full name".tr()
                    : null,
              ),
              SizedBox(height: height * 0.02),
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
              CustomTextField(
                icon: Icons.phone_android_outlined,
                label: "Phone".tr(),
                controller: phone,
                keyboard: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number".tr();
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
                label: "Password".tr(),
                obscureText: true,
                suffixIcon: Icons.visibility_off_outlined,
                controller: password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password".tr();
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters".tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.02),
              CustomTextField(
                icon: Icons.lock_outline,
                label: "Confirm Password".tr(),
                obscureText: true,
                suffixIcon: Icons.visibility_off_outlined,
                controller: confirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password".tr();
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
                          "Create Account".tr(),
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
                    final router = GoRouter.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => loading = true);
                    final user = await signInWithGoogle();
                    if (mounted) setState(() => loading = false);
                    if (user != null) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userEmail', user.email ?? '');
                      await prefs.setString('userName', user.displayName ?? 'User');
                      await prefs.setString('profileImage', user.photoURL ?? '');
                      if (mounted) router.pushReplacement(AppRouter.kNavigationView);
                    } else {
                      messenger.showSnackBar(
                        SnackBar(content: Text("google_signin_failed".tr())),
                      );
                    }
                  },
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

/// A drop-in replacement for SignInButton(Buttons.Google) that does not depend
/// on flutter_signin_button or font_awesome_flutter.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double borderRadius;

  const _GoogleSignInButton({
    super.key,
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

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        -0.52, 1.57, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        -2.09, 1.57, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        2.62, 1.05, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        1.67, 0.95, false, paint);

    paint
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.20;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.78, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
