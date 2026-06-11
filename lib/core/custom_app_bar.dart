import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? bottomWidget;
  final bool centerTitle;
    final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.bottomWidget,
    this.centerTitle = true,
        this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: appBarTheme.elevation ?? 0,
      backgroundColor:
          appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      centerTitle: centerTitle,
       iconTheme: appBarTheme.iconTheme ??

          IconThemeData(color: appBarTheme.foregroundColor ?? Colors.black87),
      title: Column(
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24.sp,
                
                  color: appBarTheme.foregroundColor ??
                      theme.colorScheme.onBackground,
                ),
          ),
          if (bottomWidget != null) ...[
            SizedBox(height: 4.h),
            bottomWidget!,
          ],
        ],
    
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
