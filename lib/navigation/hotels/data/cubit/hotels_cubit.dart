import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_state.dart';
import 'package:travel_hub/navigation/hotels/data/hotels_data.dart';

class HotelsCubit extends Cubit<HotelsState> {
  HotelsCubit() : super(HotelsInitial());

  Future<void> loadHotels(String lang) async {
    try {
      emit(HotelsLoading());
      final hotels = await EgHotels.getEgHotels(lang);
      emit(HotelsSuccess(hotels,numHotels: 10));
    } catch (e) {
      emit(HotelsError(e.toString()));
    }
  }
  void loadMoreHotels() {
    if (state is HotelsSuccess) {
      final currentState = state as HotelsSuccess;
      final total = currentState.hotels.length;
      final current = currentState.numHotels;
      int newCount =
          (current + 10 <= total) ? current + 10 : total;

      emit(currentState.copyWith(numHotels: newCount));
    }
  }
}
