import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';

class HotelsState {}

class HotelsInitial extends HotelsState {}

class HotelsLoading extends HotelsState {}

class HotelsSuccess extends HotelsState {
  final List<Hotels> hotels;
  final int numHotels;

  HotelsSuccess(this.hotels, {this.numHotels = 10});

  HotelsSuccess copyWith({List<Hotels>? hotels, int? numHotels}) {
    return HotelsSuccess(
      hotels ?? this.hotels,
      numHotels: numHotels ?? this.numHotels,
    );
  }
}

class HotelsError extends HotelsState {
  HotelsError(this.massage);
  final String massage;
}
