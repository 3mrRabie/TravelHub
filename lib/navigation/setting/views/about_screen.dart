import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/setting/widgets/info_section_card.dart';

/// About Us screen.
///
/// Root cause of Issue 2: the original screen was a single Text widget
/// containing a giant multi-line string literal — entirely hardcoded in
/// English, no localization, no theming beyond the text color, and using
/// the App default AppBar title ("About App") that was also hardcoded.
///
/// Fix:
/// • AppBar title uses 'about_us'.tr() (already in both JSON files).
/// • Every content section (subtitle, feature list, Firebase note,
///   AI note, tech stack, version, team, closing message) now uses a
///   key from the translation files resolved via .tr() at render time.
/// • Layout rebuilt with InfoSectionCard for visual consistency with the
///   Privacy screen — cards, icons, proper padding — so it looks
///   professional in both Arabic and English.
/// • Dark mode is handled automatically by the theme (Card / Text colours
///   follow theme.cardColor / theme.textTheme — no hardcoded hex values).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final text     = theme.textTheme.bodyLarge?.color  ?? Colors.black87;
    final subText  = (theme.textTheme.bodyMedium?.color ?? Colors.black54)
        .withOpacity(0.75);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'about_us'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // ── App identity banner ───────────────────────────────────────────
          Card(
            elevation: 3,
            color: kBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Icon(Icons.travel_explore,
                      color: Colors.white, size: 48.r),
                  SizedBox(height: 10.h),
                  Text(
                    'TravelHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'about_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Content sections ──────────────────────────────────────────────
          InfoSectionCard(
            icon: Icons.star_outline,
            title: 'about_features_title'.tr(),
            textColor: text,
            child: _body('about_features_body'.tr(), subText),
          ),
          SizedBox(height: 14.h),
          InfoSectionCard(
            icon: Icons.local_fire_department_outlined,
            title: 'about_firebase_title'.tr(),
            textColor: text,
            child: _body('about_firebase_body'.tr(), subText),
          ),
          SizedBox(height: 14.h),
          InfoSectionCard(
            icon: Icons.psychology_outlined,
            title: 'about_ai_title'.tr(),
            textColor: text,
            child: _body('about_ai_body'.tr(), subText),
          ),
          SizedBox(height: 14.h),
          InfoSectionCard(
            icon: Icons.code_outlined,
            title: 'about_tech_title'.tr(),
            textColor: text,
            child: _body('about_tech_body'.tr(), subText),
          ),
          SizedBox(height: 20.h),

          // ── Version & team ────────────────────────────────────────────────
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'about_version'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: subText,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'about_team_title'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...[
                    'Abdelrahman Elsedemy',
                    'Abdallah Aboelola',
                    'Amr Rabie',
                    'Mahmoud Rabea',
                    'Hossam Hussien',
                  ].map((name) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 16.r, color: kBackgroundColor),
                            SizedBox(width: 8.w),
                            Text(name,
                                style: TextStyle(
                                    fontSize: 14.sp, color: text)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Closing thanks ────────────────────────────────────────────────
          Text(
            'about_thanks'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: subText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _body(String text, Color color) => Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: color, height: 1.6),
      );
}
