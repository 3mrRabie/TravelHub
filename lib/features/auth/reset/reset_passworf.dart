import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/core/utils/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetScreen extends StatefulWidget {
  final String oobCode;

  const ResetScreen({
    super.key,
    required this.oobCode,
  });

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    if (widget.oobCode.isEmpty) {
      _showMessage('Invalid reset link');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: password,
      );
      _showMessage('Password has been reset successfully');
      GoRouter.of(context).push(AppRouter.kLoginView);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'expired-action-code' || e.code == 'invalid-action-code') {
        _showMessage('Reset link is invalid or expired');
      } else if (e.code == 'weak-password') {
        _showMessage('Password is too weak');
      } else {
        _showMessage('Something went wrong, try again later');
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
    GoRouter.of(context).go(AppRouter.kLoginView);
  }

  InputDecoration _buildPasswordDecoration(String hint, bool obscure, VoidCallback onToggle) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kWhite),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: kWhite,
          width: 1.2,
        ),
      ),
      filled: true,
      fillColor: kWhite,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isSmallHeight = size.height < 650;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(gradient: linearGradient),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isSmallHeight ? 12 : 24),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              GoRouter.of(context).go(AppRouter.kLoginView);
                            },
                            icon: Icon(Icons.arrow_circle_left_outlined,size: 28.h,color: kBlack,),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Reset your password',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kBlack
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      SizedBox(height: isSmallHeight ? 32 : 60),
                      Center(
                        child: Container(
                          width: width * 0.26 > 120 ? 120 : width * 0.26,
                          height: width * 0.26 > 120 ? 120 : width * 0.26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: loginGradient,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              (width * 0.07) > 32 ? 32 : width * 0.07,
                            ),
                            child: Image.asset(
                              AssetsData.loginLogo,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallHeight ? 40 : 80),
                      const Center(
                        child: Text(
                          'Enter your new password',
                          style: TextStyle(fontSize: 24, color: kWhite),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildPasswordDecoration(
                          'New Password',
                          _obscurePassword,
                          () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _buildPasswordDecoration(
                          'Confirm Password',
                          _obscureConfirmPassword,
                          () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPriceColor,
                            foregroundColor: kWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: kWhite)
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: isSmallHeight ? 16 : 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
