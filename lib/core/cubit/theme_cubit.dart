import 'package:flutter_bloc/flutter_bloc.dart';

/// Single source of truth for app-wide dark/light mode.
/// Provided at the root of the widget tree in MyApp so every
/// screen can read it with context.read<ThemeCubit>() and
/// toggle it with context.read<ThemeCubit>().toggleTheme().
class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false); // false = light mode

  void toggleTheme() => emit(!state);

  bool get isDarkMode => state;
}
