import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_state.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/landmarks_favorites_data.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

class LandMarkFavoritesCubit extends Cubit<LandMarkFavoritesState> {
  final LandMarkFavoritesRepository repo;

  LandMarkFavoritesCubit(this.repo) : super(LandMarkFavoritesLoading());

  Future<void> loadFavorites() async {
    try {
      emit(LandMarkFavoritesLoading());
      final data = await repo.loadFavorites();
      emit(LandMarkFavoritesLoaded(data));
    } catch (e) {
      emit(LandMarkFavoritesError(e.toString()));
    }
  }

  bool isFavorite(LandMark landMark) {
    if (state is! LandMarkFavoritesLoaded) return false;
    final favs = (state as LandMarkFavoritesLoaded).favorites;
    return favs.any((m) =>
        m.name == landMark.name && m.location == landMark.location);
  }

  Future<void> toggleFavorite(LandMark landMark) async {
    if (state is! LandMarkFavoritesLoaded) return;

    final current = (state as LandMarkFavoritesLoaded).favorites;

    if (isFavorite(landMark)) {
      await repo.removeFavorite(landMark);
      final updated = current
          .where((m) =>
              !(m.name == landMark.name && m.location == landMark.location))
          .toList();
      emit(LandMarkFavoritesLoaded(updated));
    } else {
      await repo.addFavorite(landMark);
      final updated = [...current, landMark];
      emit(LandMarkFavoritesLoaded(updated));
    }
  }

  Future<void> clearFavorites() async {
    await repo.clearFavorites();
    emit(LandMarkFavoritesLoaded([]));
  }
}

