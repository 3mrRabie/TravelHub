import 'package:flutter_bloc/flutter_bloc.dart';

class CarouselSliderCubit extends Cubit<int> {
  CarouselSliderCubit() : super(0);
  
  void changePage(int index) {
    emit(index);
  }

}
