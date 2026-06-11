import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_state.dart';
import 'package:travel_hub/navigation/land_mark/data/cubit/land_mark_cubit.dart';
import 'package:travel_hub/navigation/land_mark/data/cubit/land_mark_state.dart';

class LandMarkScreen extends StatefulWidget {
  const LandMarkScreen({super.key});

  @override
  State<LandMarkScreen> createState() => _LandMarkScreenState();
}

class _LandMarkScreenState extends State<LandMarkScreen> {
  // Same locale-tracking pattern as HotelsScreen — reloads when the
  // user switches language without navigating away first.
  String? _loadedLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    if (_loadedLang != lang) {
      _loadedLang = lang;
      context.read<LandMarkCubit>().loadLandMark(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Places to Visit".tr(),
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 24.sp),
              ),
              Text(
                "Discover amazing destinations".tr(),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16.sp),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              IconButton(icon: const Icon(Icons.favorite), onPressed: () {
                GoRouter.of(context).push(AppRouter.kLandFavoritesView);
              }),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: BlocBuilder<LandMarkCubit, LandMarkState>(
          builder: (context, state) {
            return state is LandMarkLoading
                ? Center(child: CircularProgressIndicator())
                : state is LandMarkError
                ? Center(child: Text(state.message))
                : state is LandMarkSuccess
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final landMark = state.landMark[index];
                            return GestureDetector(
                              onTap: () {
                                GoRouter.of(context).push(
                                  AppRouter.kLandMarkDetailsView,
                                  extra: landMark,
                                );
                              },
                              child: Card(
                                elevation: 5.r,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                margin: EdgeInsets.all(5.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topLeft,
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(24.r),
                                                  ),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                height: 180.h,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                imageUrl: landMark.mainImage,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(12.r),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    landMark.name,
                                                    style: TextStyle(
                                                      color: kWhite,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  Text(
                                                    landMark.location,
                                                    style: TextStyle(
                                                      color: kWhite,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        BlocBuilder<
                                          LandMarkFavoritesCubit,
                                          LandMarkFavoritesState
                                        >(
                                          builder: (context, favState) {
                                            final favCubit = context
                                                .read<LandMarkFavoritesCubit>();
                                            final isFav = favCubit.isFavorite(
                                              landMark,
                                            );

                                            return IconButton(
                                              icon: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? Colors.red
                                                    : Colors.white,
                                              ),
                                              onPressed: () {
                                                favCubit.toggleFavorite(
                                                  landMark,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.r),
                                      child: Text(
                                        landMark.shortInfo,
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: state.numMarks,
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<LandMarkCubit>().loadMoreMarks();
                          },
                          child: Text(
                            "See more".tr(),
                            style: TextStyle(color: kBackgroundColor),
                          ),
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  )
                : SizedBox();
          },
        ),
      ),
    );
  }
}
