import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

/// Help & Support screen.
///
/// Root cause of Issue 2: every string — contact card copy, FAQ section
/// heading, and all 7 question/answer pairs — was hardcoded in English.
/// Fix: FAQ items are now built from translation-key pairs that are
/// resolved at render time via .tr(), so the full screen updates when the
/// user switches language in Settings → Language without restarting.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Key pairs for the 7 FAQ items.
  // Using parallel lists instead of a list of model objects keeps this
  // simple and avoids creating a disposable data class — the question and
  // answer are looked up dynamically via .tr() inside build(), so language
  // switches are reflected immediately.
  static const List<String> _qKeys = [
    'faq_q1', 'faq_q2', 'faq_q3', 'faq_q4',
    'faq_q5', 'faq_q6', 'faq_q7',
  ];
  static const List<String> _aKeys = [
    'faq_a1', 'faq_a2', 'faq_a3', 'faq_a4',
    'faq_a5', 'faq_a6', 'faq_a7',
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color  ?? Colors.black87;
    final subColor  = (theme.textTheme.bodyMedium?.color ?? Colors.black54)
        .withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'help'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // ── Contact support card ──────────────────────────────────────────
          Card(
            elevation: 2,
            color: kBackgroundColor,
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
                      const Icon(Icons.support_agent,
                          color: Colors.white, size: 24),
                      SizedBox(width: 10.w),
                      Text(
                        'help_contact_title'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'help_contact_email'.tr(),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'help_contact_hours'.tr(),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // ── FAQ heading ───────────────────────────────────────────────────
          Text(
            'help_faq_heading'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 12.h),

          // ── FAQ accordion ─────────────────────────────────────────────────
          ...List.generate(_qKeys.length, (i) {
            final isOpen = _expanded.contains(i);
            return Card(
              elevation: 1,
              margin: EdgeInsets.only(bottom: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: () => setState(() {
                  if (isOpen) {
                    _expanded.remove(i);
                  } else {
                    _expanded.add(i);
                  }
                }),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _qKeys[i].tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: kBackgroundColor,
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        SizedBox(height: 10.h),
                        Text(
                          _aKeys[i].tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: subColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
