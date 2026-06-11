import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

class LandMarkState {}

class LandMarkInitial extends LandMarkState {}

class LandMarkLoading extends LandMarkState {}

class LandMarkSuccess extends LandMarkState {
  LandMarkSuccess(this.landMark, {this.numMarks = 10});
  final List<LandMark> landMark;
  final int numMarks;

  LandMarkSuccess copyWith({List<LandMark>? landMark, int? numMarks}) {
    return LandMarkSuccess(
      landMark ?? this.landMark,
      numMarks: numMarks ?? this.numMarks,
    );
  }
}

class LandMarkError extends LandMarkState {
  LandMarkError(this.message);
  final String message;
}
