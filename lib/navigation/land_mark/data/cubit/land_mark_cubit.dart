import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:travel_hub/navigation/land_mark/data/cubit/land_mark_state.dart';
import 'package:travel_hub/navigation/land_mark/data/land_mark_data.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

class LandMarkCubit extends Cubit<LandMarkState> {
  LandMarkCubit() : super(LandMarkInitial());
  Future<void> loadLandMark(String lang) async {
    try {
      emit(LandMarkLoading());
      final List<LandMark> landMark = await EgLandMark.getLandMark(lang);
      emit(LandMarkSuccess(landMark, numMarks: 10));
    } catch (e) {
      emit(LandMarkError(e.toString()));
    }
  }

  void loadMoreMarks() {
    if (state is LandMarkSuccess) {
      final currentState = state as LandMarkSuccess;
      final total = currentState.landMark.length;
      final current = currentState.numMarks;
      final newCount = (current + 10) <= total ? current + 10 : total;
      emit(currentState.copyWith(numMarks: newCount));
    }
  }
}
