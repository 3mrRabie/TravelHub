import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_cubit.dart';
import 'package:travel_hub/navigation/hotels/data/cubit/hotels_state.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/hotel_filters_section.dart';
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

  // ── Filter state ──────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Stored as an English city key (e.g. 'Cairo', 'All Cities').
  /// Using English keys means the selection survives locale changes and the
  /// translated city name used for comparison always matches the loaded data.
  String _selectedCityKey = 'All Cities';

  /// null = all ratings; 3 / 4 / 5 = exact star category.
  int? _selectedStars;

  RangeValues _priceRange = const RangeValues(0, kHotelMaxPrice);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    if (_loadedLang != lang) {
      _loadedLang = lang;
      context.read<HotelsCubit>().loadHotels(lang);
    }
  }

  // ── Filter helpers ────────────────────────────────────────────────────────

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCityKey != 'All Cities' ||
      _selectedStars != null ||
      _priceRange.start > 0 ||
      _priceRange.end < kHotelMaxPrice;

  List<Hotels> _applyFilters(List<Hotels> hotels) {
    // The city to compare against the hotel data (already in the current
    // locale, because the JSON is locale-specific).  'All Cities' means no
    // city restriction.
    final cityFilter =
        _selectedCityKey == 'All Cities' ? null : _selectedCityKey.tr();

    return hotels.where((hotel) {
      // ── Name search ──────────────────────────────────────────────────────
      if (_searchQuery.isNotEmpty &&
          !hotel.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // ── City ─────────────────────────────────────────────────────────────
      if (cityFilter != null && hotel.city != cityFilter) {
        return false;
      }
      // ── Star rating (exact category) ────────────────────────────────
      if (_selectedStars != null && hotel.stars != _selectedStars!) {
        return false;
      }
      // ── Price range ───────────────────────────────────────────────────────
      if (hotel.pricePerNight < _priceRange.start ||
          hotel.pricePerNight > _priceRange.end) {
        return false;
      }
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedCityKey = 'All Cities';
      _selectedStars = null;
      _priceRange = const RangeValues(0, kHotelMaxPrice);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'Hotels'.tr(),
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 24.sp,
                ),
              ),
              Text(
                'Find your perfect stay'.tr(),
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  GoRouter.of(context).push(AppRouter.kHotelsFavoritesView);
                },
              ),
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
              final filtered = _applyFilters(state.hotels);

              // When filters are active show all results (searching implies
              // you want to see everything that matches, not just the first 10).
              // Otherwise respect the pagination cursor.
              final displayed = _hasActiveFilters
                  ? filtered
                  : filtered.take(state.numHotels).toList();

              final canLoadMore = !_hasActiveFilters &&
                  state.numHotels < state.hotels.length;

              return Column(
                children: [
                  // ── Filter section ─────────────────────────────────────
                  HotelFiltersSection(
                    searchController: _searchController,
                    selectedCityKey: _selectedCityKey,
                    selectedStars: _selectedStars,
                    priceRange: _priceRange,
                    hasActiveFilters: _hasActiveFilters,
                    onSearchChanged: (q) => setState(() => _searchQuery = q),
                    onCityChanged: (key) =>
                        setState(() => _selectedCityKey = key),
                    onRatingChanged: (r) =>
                        setState(() => _selectedStars = r),
                    onPriceRangeChanged: (r) =>
                        setState(() => _priceRange = r),
                    onClearFilters: _clearFilters,
                  ),
                  SizedBox(height: 4.h),

                  // ── Hotel list ─────────────────────────────────────────
                  Expanded(
                    child: HotelsList(
                      hotels: displayed,
                      canLoadMore: canLoadMore,
                      onLoadMore: () =>
                          context.read<HotelsCubit>().loadMoreHotels(),
                      isEmpty: filtered.isEmpty,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
