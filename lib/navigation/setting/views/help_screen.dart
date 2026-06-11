import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      q: 'How do I book a hotel?',
      a: 'Open the Hotels tab, browse or search for a hotel, tap it to '
          'view its details, then press "Book Now". Fill in your travel '
          'dates, number of guests, and contact details, then tap '
          '"Complete Booking".',
    ),
    _FaqItem(
      q: 'Can I cancel a reservation?',
      a: 'TravelHub is currently a demo application. In the live version, '
          'cancellation policies will be shown per hotel. You will be able '
          'to cancel from your booking history.',
    ),
    _FaqItem(
      q: 'How do I change the language?',
      a: 'Go to Settings → Language, then choose English or Arabic. '
          'The language switches instantly across the whole app.',
    ),
    _FaqItem(
      q: 'How do I switch to dark mode?',
      a: 'Tap the Dark Mode / Light Mode button at the top of the '
          'Settings screen. The theme changes immediately.',
    ),
    _FaqItem(
      q: 'How does the AI Camera work?',
      a: 'Tap the AI Camera option on the home screen. Point your camera '
          'at any landmark or place. The AI will identify it and provide '
          'an audio-narrated description.',
    ),
    _FaqItem(
      q: 'How do I save a favourite hotel or landmark?',
      a: 'Tap the heart icon on any hotel card or landmark card. '
          'Access all your favourites from the heart button in the '
          'top-right corner of the Hotels or Places screen.',
    ),
    _FaqItem(
      q: 'I forgot my password. What do I do?',
      a: 'On the Login screen tap "Forgot Password?". Enter your email '
          'address and we will send you a reset link.',
    ),
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final subColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black54;

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
          'help'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          // Contact card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            color: kBackgroundColor,
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
                        'Contact Support',
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
                    'support@travelhub.app',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Available Sunday – Thursday, 9 AM – 5 PM (EET)',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 12.h),

          // FAQ accordion
          ...List.generate(_faqs.length, (i) {
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _faqs[i].q,
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
                          _faqs[i].a,
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

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}
