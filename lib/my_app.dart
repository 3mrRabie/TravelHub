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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeCubit lives here — above auth, above everything.
    // Any screen in the tree can call context.read<ThemeCubit>().toggleTheme()
    // and the MaterialApp themeMode will update instantly.
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: ScreenUtilInit(
        designSize: const Size(393, 851),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDarkMode) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;

                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                  }

                  if (user == null) {
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
                      child: MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                        routerConfig: AppRouter.routers,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
