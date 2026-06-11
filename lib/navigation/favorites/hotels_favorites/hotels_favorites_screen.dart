import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_state.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/hotel_list.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Hotels"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              context.read<FavoritesCubit>().clearFavorites();
            },
          )
        ],
      ),

      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return Center(child: Text("No favorites yet"));
            }

            return ListView.builder(
              padding: EdgeInsetsDirectional.all(16.r),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final hotel = state.favorites[index];
                return HotelCard(hotel: hotel);
              },
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}