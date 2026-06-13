import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_hub/core/cubit/theme_cubit.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/core/utils/app_theme.dart';
import 'package:travel_hub/core/utils/deep_link_listener.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/cubit/hotels_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/data/hotels_favorites_data.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/cubit/landmarks_favorites_cubit.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/data/landmarks_favorites_data.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_cubit.dart';
import 'package:travel_hub/navigation/land_mark/data/cubit/land_mark_cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Cached ONCE for the lifetime of MyApp.
  //
  // FirebaseAuth.instance.authStateChanges() is implemented with `.map()`,
  // so it returns a *new* Stream<User?> instance every time it is called -
  // even though it wraps the same underlying broadcast stream. If it were
  // called again inside build(), the StreamBuilder below would see a
  // different `stream` on every rebuild, unsubscribe/resubscribe, and
  // briefly report ConnectionState.waiting. Caching it here keeps the
  // stream identity stable across rebuilds (theme toggles, locale changes,
  // orientation changes, etc.) - see ThemeCubit notes below for why this
  // matters.
  late final Stream<User?> _authStateChanges =
      FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    // ThemeCubit lives here - above auth, above everything.
    // Any screen in the tree can call context.read<ThemeCubit>().toggleTheme()
    // and the MaterialApp themeMode will update instantly.
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: ScreenUtilInit(
        designSize: const Size(393, 851),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // IMPORTANT ORDERING - StreamBuilder<User?> is the OUTER widget,
          // BlocBuilder<ThemeCubit, bool> is the INNER widget.
          //
          // Auth-state changes (sign in / sign out) are rare and SHOULD
          // rebuild the whole app - a fresh MultiBlocProvider + router makes
          // sense in that case.
          //
          // Theme toggles are frequent and must NOT touch this StreamBuilder
          // at all. BlocBuilder<ThemeCubit, bool> is now the *innermost*
          // widget and directly returns MaterialApp / MaterialApp.router
          // with the updated theme/themeMode. Because routerConfig
          // (AppRouter.routers) is a single cached GoRouter instance and the
          // returned widget's runtimeType stays the same across theme
          // toggles, Flutter updates the existing Router element in place -
          // the whole navigation tree (including MainScreen's selected
          // bottom-nav tab) is preserved, so toggling the theme from
          // Settings keeps the user on Settings.
          return StreamBuilder<User?>(
            stream: _authStateChanges,
            builder: (context, snapshot) {
              final user = snapshot.data;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return BlocBuilder<ThemeCubit, bool>(
                  builder: (context, isDarkMode) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                      home: const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                );
              }

              if (user == null) {
                return BlocBuilder<ThemeCubit, bool>(
                  builder: (context, isDarkMode) {
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                      routerConfig: AppRouter.routers,
                    );
                  },
                );
              }

              return MultiBlocProvider(
                key: ValueKey(user.uid),
                providers: [
                  BlocProvider(
                    create: (_) => FavoritesCubit(
                      FavoritesRepository(
                        firestore: FirebaseFirestore.instance,
                        auth: FirebaseAuth.instance,
                      ),
                    )..loadFavorites(),
                  ),
                  BlocProvider(
                    create: (_) => LandMarkFavoritesCubit(
                      LandMarkFavoritesRepository(
                        firestore: FirebaseFirestore.instance,
                        auth: FirebaseAuth.instance,
                      ),
                    )..loadFavorites(),
                  ),
                  BlocProvider(create: (_) => HotelsCubit()),
                  BlocProvider(create: (_) => LandMarkCubit()),
                ],
                child: DeepLinkListener(
                  child: BlocBuilder<ThemeCubit, bool>(
                    builder: (context, isDarkMode) {
                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode:
                            isDarkMode ? ThemeMode.dark : ThemeMode.light,
                        routerConfig: AppRouter.routers,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
