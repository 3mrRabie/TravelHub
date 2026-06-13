import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_state.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/hotel_list.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorite_hotels'.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => context.read<FavoritesCubit>().clearFavorites(),
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return Center(child: Text('no_favorites_yet'.tr()));
            }
            return ListView.builder(
              padding: EdgeInsetsDirectional.all(16.r),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) =>
                  HotelCard(hotel: state.favorites[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}