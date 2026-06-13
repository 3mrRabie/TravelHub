import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

/// A titled, icon-prefixed card used by the Privacy, Help and About pages
/// for consistent "info section" styling.
///
/// [title] is shown next to [icon] in a bold header row, and [child] is
/// rendered below it - typically a [Text] widget for a paragraph, or a
/// [Column] of bullet rows for a feature list. Extracted from the old
/// Privacy-screen-only `_SectionCard` so Privacy, Help and About all share
/// the same card chrome instead of each re-implementing it.
class InfoSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;
  final Widget child;

  const InfoSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.textColor,
    required this.child,
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            child,
          ],
        ),
      ),
    );
  }
}
