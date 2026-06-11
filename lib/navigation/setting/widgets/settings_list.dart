import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_cubit.dart';
import 'package:travel_hub/navigation/land_mark/data/cubit/land_mark_cubit.dart';
import 'package:travel_hub/navigation/setting/views/about_screen.dart';
import 'package:travel_hub/navigation/setting/views/help_screen.dart';
import 'package:travel_hub/navigation/setting/views/privacy_screen.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 20.w,
        vertical: 10.h,
      ),
      children: [
        _buildSectionTitle(tr('account'), color: Colors.blueAccent),
        _buildSettingItem(
          Icons.lock_outline,
          tr('privacy'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyScreen()),
          ),
        ),
        _buildLanguageItem(context),
        SizedBox(height: 15.h),

        _buildSectionTitle(tr('support'), color: Colors.blueAccent),
        _buildSettingItem(
          Icons.help_outline,
          tr('help'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          ),
        ),
        SizedBox(height: 15.h),

        _buildSectionTitle(tr('more'), color: Colors.blueAccent),
        _buildSettingItem(
          Icons.info_outline,
          tr('about_us'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),

        _buildLogoutItem(context),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 8.0.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueAccent),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    return ListTile(
      leading:
          const Icon(Icons.language_outlined, color: Colors.blueAccent),
      title: Text(tr('language')),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: () => _showLanguageDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final bgColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.language, color: Colors.blueAccent),
            SizedBox(width: 8.w),
            Text(
              tr('choose_language'),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangOption(
              context,
              label: "english".tr(),
              locale: const Locale('en'),
              textColor: textColor,
            ),
            const Divider(),
            _buildLangOption(
              context,
              label: "arabic".tr(),
              locale: const Locale('ar'),
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(
    BuildContext context, {
    required String label,
    required Locale locale,
    required Color textColor,
  }) {
    final isSelected = context.locale == locale;

    return InkWell(
      onTap: () {
        context.setLocale(locale);
        // Reload data in the correct language immediately.
        // HotelsScreen and LandMarkScreen also track locale themselves,
        // but triggering here covers the case where those screens are
        // already loaded and sitting in the background.
        context.read<HotelsCubit>().loadHotels(locale.languageCode);
        context.read<LandMarkCubit>().loadLandMark(locale.languageCode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          vertical: 10.h,
          horizontal: 12.w,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Colors.blueAccent
                  : textColor.withOpacity(0.6),
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return _buildSettingItem(
      Icons.logout,
      tr('logout'),
      color: kRed,
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(tr('logout'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(tr('confirm_logout'),
                style: const TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(tr('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(tr('confirm'),
                    style: const TextStyle(color: kRed)),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userName');
        await prefs.remove('userEmail');
        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          GoRouter.of(context).go(AppRouter.kLoginView);
        }
      },
    );
  }
}
