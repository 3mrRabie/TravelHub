import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_state.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/hotels_favorites_data.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repo;

  FavoritesCubit(this.repo) : super(FavoritesLoading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      emit(FavoritesLoading());
      final data = await repo.loadFavorites();
      emit(FavoritesLoaded(data));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  bool isFavorite(Hotels hotel) {
    if (state is! FavoritesLoaded) return false;
    final favs = (state as FavoritesLoaded).favorites;
    return favs.any((h) => h.bookingUrl == hotel.bookingUrl);
  }

  Future<void> toggleFavorite(Hotels hotel) async {
    if (state is! FavoritesLoaded) return;

    final current = (state as FavoritesLoaded).favorites;

    if (isFavorite(hotel)) {
      await repo.removeFavorite(hotel.bookingUrl);
      final updated = current
          .where((h) => h.bookingUrl != hotel.bookingUrl)
          .toList();
      emit(FavoritesLoaded(updated));
    } else {
      await repo.addFavorite(hotel);
      final updated = [...current, hotel];
      emit(FavoritesLoaded(updated));
    }
  }

  Future<void> clearFavorites() async {
    await repo.clearFavorites();
    emit(FavoritesLoaded([]));
  }
}
