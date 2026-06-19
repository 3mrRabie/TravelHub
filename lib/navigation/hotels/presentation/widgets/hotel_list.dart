import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/currency_formatter.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_state.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_cubit.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_state.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';
import 'custom_button.dart';

class HotelsList extends StatelessWidget {
  final HotelsSuccess state;

  const HotelsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.numHotels,
            itemBuilder: (context, index) {
              final hotel = state.hotels[index];
              return HotelCard(hotel: hotel);
            },
          ),

          TextButton(
            onPressed: () {
              context.read<HotelsCubit>().loadMoreHotels();
            },
            child: Text(
              "See more".tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotels hotel;
  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRouter.kHotelsDetailsView, extra: hotel);
      },
      child: Card(
        elevation: 5,
        color: theme.cardColor,
        shadowColor: isDark ? Colors.white54 : Colors.black26, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        margin: EdgeInsetsDirectional.all(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Stack(
              children: [
                _HotelImage(imageUrl: hotel.imageUrl, stars: hotel.stars.toDouble()),
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen: (prev, curr) => curr is FavoritesLoaded || curr is FavoritesLoading,
                  builder: (context, favState) {
                    final favCubit = context.read<FavoritesCubit>();
                    final isFav = favCubit.isFavorite(hotel);

                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        favCubit.toggleFavorite(hotel);
                      },
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.all(12.r),
              child: Column(
                children: [
                  HotelInfoRow(
                    leftText: hotel.name,
                    rightText: CurrencyFormatter.format(hotel.pricePerNight),
                    leftColor: theme.textTheme.bodyMedium?.color ?? kBlack,
                    rightColor: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 4.h),
                  HotelInfoRow(
                    leftText: hotel.city,
                    rightText: "per night".tr(),
                    leftColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? kAssets,
                    rightColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? kAssets,
                  ),
                  SizedBox(height: 10.h),
                  CustomButton(
                    buttonText: "Book Now".tr(),
                    onPressed: () => GoRouter.of(context).push(
                      AppRouter.kBookView,
                      extra: hotel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelImage extends StatelessWidget {
  final String imageUrl;
  final double stars;
  const _HotelImage({required this.imageUrl, required this.stars});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      // AlignmentDirectional.topEnd (not Alignment.topRight): the favorite
      // heart button in the parent Stack sits at the default
      // AlignmentDirectional.topStart, which becomes top-RIGHT in RTL. Using
      // a physical `Alignment.topRight` here would put the rating badge on
      // top of that heart button in Arabic. `topEnd` keeps the badge on the
      // opposite corner from the heart in both directions.
      alignment: AlignmentDirectional.topEnd,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: CachedNetworkImage(
            height: 180.h,
            width: double.infinity,
            fit: BoxFit.cover,
            imageUrl: imageUrl,
            placeholder: (context, url) => Container(
              height: 180.h,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180.h,
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Text('Image unavailable', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.all(8.r),
          width: 62.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : kWhite,
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white24 : Colors.black26,
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rate, color: Colors.amber, size: 18.sp),
              SizedBox(width: 3.w),
              Text(
                stars.toString(),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? kBlack),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row showing two pieces of hotel info side by side - e.g. hotel name +
/// price, or city + "per night". Used by [HotelCard] (in the hotel list and
/// favorites list) and reused by the hotel details screen for the
/// name/reviews and city/"reviews" rows.
///
/// [leftText] hugs the row's leading edge and [rightText] hugs the trailing
/// edge, using [AlignmentDirectional] so the layout mirrors correctly for
/// RTL locales (Arabic) instead of staying pinned to the physical
/// left/right. Both texts are constrained to a single line with an ellipsis
/// so long hotel names (in either language) never clip into or overlap the
/// other side of the row.
class HotelInfoRow extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color leftColor;
  final Color rightColor;
  final double? fontSize;

  const HotelInfoRow({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.leftColor,
    required this.rightColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = fontSize ?? 16.sp;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              leftText,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(color: leftColor, fontSize: size),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              rightText,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(color: rightColor, fontSize: size),
            ),
          ),
        ),
      ],
    );
  }
}
