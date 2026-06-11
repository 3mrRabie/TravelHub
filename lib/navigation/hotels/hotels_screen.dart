import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/custom_app_bar.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_cubit.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_state.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/hotel_list.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  // Track the last-loaded language so we reload automatically when the
  // user switches locale without having to navigate away and back.
  String? _loadedLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    if (_loadedLang != lang) {
      _loadedLang = lang;
      context.read<HotelsCubit>().loadHotels(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hotels".tr(),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 24.sp),
              ),
              Text(
                "Find your perfect stay".tr(),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16.sp),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              IconButton(icon: const Icon(Icons.favorite), onPressed: () {
                GoRouter.of(context).push(AppRouter.kHotelsFavoritesView);
              }),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsDirectional.all(16.r),
        child: BlocBuilder<HotelsCubit, HotelsState>(
          builder: (context, state) {
            if (state is HotelsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HotelsError) {
              return Center(
                child: Text(
                  state.massage,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            } else if (state is HotelsSuccess) {
              return HotelsList(state: state);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
