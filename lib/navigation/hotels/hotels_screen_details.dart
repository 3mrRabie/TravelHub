import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/core/utils/currency_formatter.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/custom_button.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/hotel_list.dart';

class HotelsScreenDetails extends StatelessWidget {
  final Hotels hotels;
  const HotelsScreenDetails(this.hotels, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 85.w),
            Text(
              "Hotel Details".tr(),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16.sp),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CachedNetworkImage( fit: BoxFit.cover, imageUrl: hotels.imageUrl,
                 placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                children: [
                  HotelInfoRow(
                    leftText: hotels.name,
                    rightText: "${hotels.reviewsCount}",
                    leftColor: Theme.of(context).textTheme.bodyLarge?.color ?? kBlack,
                    rightColor: Theme.of(context).textTheme.bodyMedium?.color ?? kBlack,
                  ),
                  SizedBox(height: 4.h),
                  HotelInfoRow(
                    leftText: hotels.city,
                    rightText: "reviews".tr(),
                    leftColor: Theme.of(context).textTheme.bodyMedium?.color ?? kBlack,
                    rightColor: Theme.of(context).textTheme.bodyMedium?.color ?? kBlack,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star_rate, color: kStar),
                      SizedBox(width: 3.w),
                      Text(
                        "${hotels.stars}",
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              elevation: 5.r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About".tr(),
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18.sp),
                    ),
                    Text(
                      hotels.description,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5.r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Features".tr(),
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18.sp),
                    ),
                    ...List.generate(hotels.facilities.length, (index) {
                      return Row(
                        children: [
                          Icon(Icons.check, color: KCheck),
                          Expanded(
                            child: Text(
                              " ${hotels.facilities[index]}",
                              softWrap: true,
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16.sp),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5.r,
              color: kBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Price per night".tr(),
                              style: TextStyle(color: kWhite, fontSize: 14.sp),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              CurrencyFormatter.format(hotels.pricePerNight),
                              style: TextStyle(color: kWhite, fontSize: 16.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomButton(
                      buttonText: "Book Now".tr(),
                      buttonColor: kWhite,
                      textColor: kBackgroundColor,
                      onPressed: () {
                        GoRouter.of(context).push(
                          AppRouter.kBookView,
                          extra: hotels, // passes hotel data to BookScreen
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
