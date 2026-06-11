import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_state.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

class LandMarkFavoritesScreen extends StatelessWidget {
  const LandMarkFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Places"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              context.read<LandMarkFavoritesCubit>().clearFavorites();
            },
          ),
        ],
      ),
      body: BlocBuilder<LandMarkFavoritesCubit, LandMarkFavoritesState>(
        builder: (context, state) {
          if (state is LandMarkFavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LandMarkFavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(child: Text("No favorite places yet"));
            }

            return ListView.builder(
              padding: EdgeInsetsDirectional.all(16.r),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final landMark = state.favorites[index];

                return GestureDetector(
                  onTap: () {
                    GoRouter.of(
                      context,
                    ).push(AppRouter.kLandMarkDetailsView, extra: landMark);
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
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
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
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                              buildWhen: (prev, curr) => curr is LandMarkFavoritesLoaded || curr is LandMarkFavoritesLoading,
                              builder: (context, favState) {
                                final favCubit = context
                                    .read<LandMarkFavoritesCubit>();
                                final isFav = favCubit.isFavorite(landMark);

                                return IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    favCubit.toggleFavorite(landMark);
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
            );
          }

          if (state is LandMarkFavoritesError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
