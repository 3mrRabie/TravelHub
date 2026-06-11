import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/home/home_screen.dart';
import 'package:travel_hub/navigation/hotels/hotels_screen.dart';
import 'package:travel_hub/navigation/land_mark/land_mark_screen.dart';
import 'package:travel_hub/navigation/maps/presentation/views/full_map_screen.dart';
import 'package:travel_hub/navigation/setting/views/setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;

    // Pages are created inside build() so they always pick up the current
    // theme, locale, and any other inherited data on each rebuild.
    // Flutter's element-reconciliation keeps each page's State alive even
    // though the widget objects are recreated — no state is lost.
    final pages = <Widget>[
      HomeScreen(onTabSelected: _onItemTapped),
      const HotelsScreen(),
      const LandMarkScreen(),
      const FullMapScreen(),
      const SettingScreen(), // No props — reads ThemeCubit directly
    ];

    // IMPORTANT: No MaterialApp wrapper here.
    // MainScreen lives inside MyApp's MaterialApp.router.
    // Adding another MaterialApp would shadow the outer theme, localization,
    // and navigation config — causing the dark-mode and language bugs.
    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kBackgroundColor,
        unselectedItemColor: kGrey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: isWide ? 14 : 12,
        unselectedFontSize: isWide ? 12 : 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "Home".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.hotel),
            label: "Hotels".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.place),
            label: "Places".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: "Map".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: "Settings".tr(),
          ),
        ],
      ),
    );
  }
}
