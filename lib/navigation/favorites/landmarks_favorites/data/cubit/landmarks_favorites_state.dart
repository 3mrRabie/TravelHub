import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

abstract class LandMarkFavoritesState {}

class LandMarkFavoritesLoading extends LandMarkFavoritesState {}

class LandMarkFavoritesLoaded extends LandMarkFavoritesState {
  final List<LandMark> favorites;
  LandMarkFavoritesLoaded(this.favorites);
}

class LandMarkFavoritesError extends LandMarkFavoritesState {
  final String message;
  LandMarkFavoritesError(this.message);
}

