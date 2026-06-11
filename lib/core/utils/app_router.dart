import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/features/ai_camera/ai_camera.dart';
import 'package:travel_hub/features/auth/forget_password/forget.dart';
import 'package:travel_hub/features/auth/forget_password/success.dart';
import 'package:travel_hub/features/auth/login/presentation/views/login_screen.dart';
import 'package:travel_hub/features/auth/register/view/register_screen.dart';
import 'package:travel_hub/features/auth/reset/reset_passworf.dart';
import 'package:travel_hub/features/welcome/welcome_screen.dart';
import 'package:travel_hub/navigation/favorites/hotels_favorites/hotels_favorites_screen.dart';
import 'package:travel_hub/navigation/favorites/landmarks_favorites/landmarks_favorites_screen.dart';
import 'package:travel_hub/navigation/land_mark/data/carousel_slider_cubit/carousel_slider_cubit.dart';
import 'package:travel_hub/navigation/land_mark/land_mark_details_screen.dart';
import 'package:travel_hub/navigation/land_mark/land_mark_screen.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';
import 'package:travel_hub/navigation/home/home_screen.dart';
import 'package:travel_hub/navigation/hotels/booking/book_screen.dart';
import 'package:travel_hub/navigation/hotels/hotels_screen.dart';
import 'package:travel_hub/features/splash/splash_screen.dart';
import 'package:travel_hub/navigation/hotels/hotels_screen_details.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';
import 'package:travel_hub/navigation/main_screen.dart';
import 'package:travel_hub/navigation/maps/presentation/views/full_map_screen.dart';
import 'package:travel_hub/navigation/setting/views/about_screen.dart';

abstract class AppRouter {
  static const kWelcomeView = '/welcomeView';
  static const kLoginView = '/loginView';
  static const kRegisterView = '/registerView';
  static const kForgetView = '/forgetView';
  static const kReset = '/restView';
  static const kSuccess = '/success';

  //Navigation Feature
  static const kNavigationView = '/navigation';
  static const kMapView = '/mapView';
  //Home Feature
  static const kHomeView = '/home';
  static const kCameraView = '/cameraView';

  //Hotels Feature
  static const kHotelsView = '/hotels';
  static const kBookView = '/book';
  static const kHotelsDetailsView = '/details';
  //Land Mark Feature
  static const kLandMarkView = '/landMark';
  static const kLandMarkDetailsView = '/marksDetails';

  //Favorites Feature
  static const kHotelsFavoritesView = '/hotelsFavorites';
  static const kLandFavoritesView = '/landFavorites';
 static const kAboutView = '/aboutView';
  static final routers = GoRouter(
   redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;

      final isPublicRoute = loc == '/' ||
          loc == kLoginView ||
          loc == kRegisterView ||
          loc == kForgetView ||
          loc == kWelcomeView ||
          loc == kSuccess ||
          loc == kReset ||
          loc.startsWith('//auth/action');

      if (user == null) {
        if (isPublicRoute) return null;
        return kLoginView;
      } else {
        final isAuthRoute = loc == kLoginView ||
            loc == kRegisterView ||
            loc == kForgetView ||
            loc == kWelcomeView;
        if (isAuthRoute) return kNavigationView;
        return null;
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: kWelcomeView,
        builder: (context, state) => const TravelWelcomeScreen(),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: kRegisterView,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: kForgetView,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: kReset,
        builder: (context, state) => const ResetScreen(oobCode: '',),
      ),
       GoRoute(
        path: kSuccess,
        builder: (context, state) => const SuccessScreen(),
      ),

      GoRoute(
        path: '/__/auth/action',
        builder: (context, state) {
          final uri = state.uri;
          final mode = uri.queryParameters['mode'];
          final oobCode = uri.queryParameters['oobCode'];

          if (mode == 'resetPassword' && oobCode != null) {
            return ResetScreen(oobCode: oobCode);
          }

          return const Scaffold(
            body: Center(
              child: Text('Invalid or unsupported link'),
            ),
          );
        },
      ),

      //Home Feature
      GoRoute(path: kHomeView, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: kCameraView,
        builder: (context, state) {
          final imageFile = state.extra as File;
          return AiCamera(selectedImage: imageFile);
        },
      ),
      //Navigation Feature
      GoRoute(
        path: kNavigationView,
        builder: (context, state) => const MainScreen(),
      ),

      GoRoute(
        path: kMapView,
        builder: (context, state) => const FullMapScreen(),
      ),

      GoRoute(
        path: kHotelsView,
        builder: (context, state) => const HotelsScreen(),
      ),
      GoRoute(
        path: kHotelsDetailsView,
        pageBuilder: (context, state) {
          final hotels = state.extra as Hotels;
          return CustomTransitionPage(
            key: state.pageKey,
            child: HotelsScreenDetails(hotels),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
      
      GoRoute(
        path: kLandMarkView,
        builder: (context, state) => const LandMarkScreen(),
      ),
      GoRoute(
        path: kLandMarkDetailsView,
        pageBuilder: (context, state) {
          final landMark = state.extra as LandMark;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => CarouselSliderCubit(),
              child: LandMarkDetailsScreen(landMark),
            ),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),

      GoRoute(path: kBookView, builder: (context, state) => const BookScreen()),
       GoRoute(
        path: kHotelsFavoritesView,
        builder: (context, state) => FavoritesScreen(),
      ),
      GoRoute(
        path: kLandFavoritesView,
        builder: (context, state) => LandMarkFavoritesScreen(),
      ),
      GoRoute(
        path: kAboutView,
        builder: (context, state) => AboutScreen(),
      ),
    ],
  );
}
