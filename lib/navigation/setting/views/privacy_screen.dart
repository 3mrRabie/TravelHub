import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/setting/widgets/info_section_card.dart';

/// Privacy & Data Policy screen.
///
/// Root cause of Issue 2: every content string was hardcoded in English.
/// Fix: each title and body paragraph is now looked up from the
/// easy_localization translation files via .tr(), so switching the app
/// language (Settings → Language) updates this page instantly without
/// restarting the app. The private _SectionCard widget has been replaced
/// by the shared InfoSectionCard from info_section_card.dart to avoid
/// duplicate widget code across Privacy / Help / About (req #8).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final text    = theme.textTheme.bodyLarge?.color  ?? Colors.black87;
    final subText = (theme.textTheme.bodyMedium?.color ?? Colors.black54)
        .withOpacity(0.7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
          InfoSectionCard(
            icon: Icons.shield_outlined,
            title: 'privacy_collect_title'.tr(),
            textColor: text,
            child: _body('privacy_collect_body'.tr(), subText),
          ),
          SizedBox(height: 16.h),
          InfoSectionCard(
            icon: Icons.storage_outlined,
            title: 'privacy_use_title'.tr(),
            textColor: text,
            child: _body('privacy_use_body'.tr(), subText),
          ),
          SizedBox(height: 16.h),
          InfoSectionCard(
            icon: Icons.lock_outline,
            title: 'privacy_security_title'.tr(),
            textColor: text,
            child: _body('privacy_security_body'.tr(), subText),
          ),
          SizedBox(height: 16.h),
          InfoSectionCard(
            icon: Icons.person_outline,
            title: 'privacy_rights_title'.tr(),
            textColor: text,
            child: _body('privacy_rights_body'.tr(), subText),
          ),
          SizedBox(height: 16.h),
          InfoSectionCard(
            icon: Icons.cookie_outlined,
            title: 'privacy_cookies_title'.tr(),
            textColor: text,
            child: _body('privacy_cookies_body'.tr(), subText),
          ),
          SizedBox(height: 24.h),
          Text(
            'privacy_last_updated'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: subText),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _body(String text, Color color) => Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: color, height: 1.6),
      );
}
