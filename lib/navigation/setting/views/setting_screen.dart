import 'package:flutter/material.dart';
import 'package:travel_hub/navigation/setting/widgets/settings_header.dart';
import 'package:travel_hub/navigation/setting/widgets/settings_list.dart';

/// Setting screen no longer takes isDarkMode / onToggleTheme props.
/// Both are handled internally via ThemeCubit (provided at MyApp level).
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: const [
            SettingsHeader(),
            Expanded(child: SettingsList()),
          ],
        ),
      ),
    );
  }
}
