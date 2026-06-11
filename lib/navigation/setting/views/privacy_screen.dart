import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final subColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
        ?? Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'privacy'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          _SectionCard(
            icon: Icons.shield_outlined,
            title: 'Data We Collect',
            body:
                'TravelHub collects your name, email address, phone number, '
                'and profile photo to create and personalise your account. '
                'We also collect booking details and travel preferences to '
                'provide relevant hotel and landmark recommendations.',
            textColor: textColor,
            subColor: subColor,
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            icon: Icons.storage_outlined,
            title: 'How We Use Your Data',
            body:
                'Your data is used solely to operate TravelHub services: '
                'processing bookings, displaying personalised content, '
                'and sending transactional notifications. '
                'We do not sell your personal information to third parties.',
            textColor: textColor,
            subColor: subColor,
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            icon: Icons.lock_outline,
            title: 'Data Security',
            body:
                'All data is stored on Firebase — a Google Cloud service — '
                'and is encrypted in transit and at rest. '
                'We enforce strict access controls and conduct regular '
                'security reviews to keep your data safe.',
            textColor: textColor,
            subColor: subColor,
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            icon: Icons.person_outline,
            title: 'Your Rights',
            body:
                'You may request to view, update, or delete your personal '
                'data at any time by contacting support. '
                'You can also delete your account from within the app, '
                'which will permanently remove all associated data.',
            textColor: textColor,
            subColor: subColor,
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            icon: Icons.cookie_outlined,
            title: 'Cookies & Local Storage',
            body:
                'TravelHub uses local storage to remember your language '
                'preference and session state. '
                'No advertising cookies or third-party trackers are used.',
            textColor: textColor,
            subColor: subColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'Last updated: June 2025',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: subColor),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color textColor;
  final Color subColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kBackgroundColor, size: 22.r),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              body,
              style: TextStyle(
                fontSize: 14.sp,
                color: subColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
