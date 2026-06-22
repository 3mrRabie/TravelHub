import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/currency_formatter.dart';

/// Maximum price used as the upper bound of the price-range slider.
const double kHotelMaxPrice = 30000;

/// English keys for each city chip. The display label is always
/// [cityKey.tr()] so it renders correctly in both EN and AR.
/// The parent stores these English keys so that selection persists
/// across locale changes and the comparison in [_applyFilters]
/// can translate the key to match whatever language the data was
/// loaded in (arabic JSON ↔ english JSON).
const List<String> kHotelCityKeys = [
  'All Cities',
  'Cairo',
  'Alexandria',
  'Sharm El Sheikh',
  'Hurghada',
  'Luxor',
  'Aswan',
];

class HotelFiltersSection extends StatelessWidget {
  final TextEditingController searchController;

  /// Stored as an English city key (e.g. 'Cairo', 'All Cities').
  final String selectedCityKey;

  /// null = show all ratings; 3 / 4 / 5 = exact star category.
  final int? selectedStars;

  final RangeValues priceRange;
  final bool hasActiveFilters;

  final ValueChanged<String> onSearchChanged;

  /// Receives the English city key (e.g. 'Cairo', 'All Cities').
  final ValueChanged<String> onCityChanged;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final VoidCallback onClearFilters;

  const HotelFiltersSection({
    super.key,
    required this.searchController,
    required this.selectedCityKey,
    required this.selectedStars,
    required this.priceRange,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onCityChanged,
    required this.onRatingChanged,
    required this.onPriceRangeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = theme.textTheme.bodyLarge?.color;
    final mutedColor =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search bar ────────────────────────────────────────────────────
        _HotelSearchBar(
          controller: searchController,
          onChanged: onSearchChanged,
          isDark: isDark,
        ),
        SizedBox(height: 14.h),

        // ── "Filters" label + "Clear" link ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'hotel_filters'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: bodyColor,
              ),
            ),
            if (hasActiveFilters)
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: kBackgroundColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    'hotel_filter_clear'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kBackgroundColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),

        // ── City filter chips (horizontal scroll) ─────────────────────────
        SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kHotelCityKeys.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final key = kHotelCityKeys[index];
              return _HotelChip(
                label: key.tr(),
                isSelected: selectedCityKey == key,
                onTap: () => onCityChanged(key),
                isDark: isDark,
              );
            },
          ),
        ),
        SizedBox(height: 8.h),

        // ── Rating filter chips ────────────────────────────────────────────
        Row(
          children: [
            _HotelChip(
              label: 'hotel_all_ratings'.tr(),
              isSelected: selectedStars == null,
              onTap: () => onRatingChanged(null),
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _HotelChip(
              label: 'hotel_5_stars'.tr(),
              isSelected: selectedStars == 5,
              onTap: () => onRatingChanged(5),
              icon: Icons.star_rounded,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _HotelChip(
              label: 'hotel_4_stars'.tr(),
              isSelected: selectedStars == 4,
              onTap: () => onRatingChanged(4),
              icon: Icons.star_rounded,
              isDark: isDark,
            ),
            SizedBox(width: 8.w),
            _HotelChip(
              label: 'hotel_3_stars'.tr(),
              isSelected: selectedStars == 3,
              onTap: () => onRatingChanged(3),
              icon: Icons.star_rounded,
              isDark: isDark,
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Price range slider ─────────────────────────────────────────────
        _PriceRangeSlider(
          priceRange: priceRange,
          isDark: isDark,
          bodyColor: bodyColor,
          mutedColor: mutedColor,
          onChanged: onPriceRangeChanged,
        ),
      ],
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────

class _HotelSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _HotelSearchBar({
    required this.controller,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Use a ValueListenableBuilder so the clear (×) button appears /
    // disappears reactively without needing a parent setState.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'hotel_search_hint'.tr(),
            hintStyle: TextStyle(color: kAssets, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: kAssets, size: 22.sp),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: kAssets, size: 18.sp),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: kAssets),
            ),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        );
      },
    );
  }
}

// ── Generic Chip ───────────────────────────────────────────────────────────────

class _HotelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDark;

  const _HotelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? kBackgroundColor
              : (isDark ? Colors.grey[800] : kLightGrey),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12.sp,
                color: isSelected ? kStar : kAssets,
              ),
              SizedBox(width: 3.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : kText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Price Range Slider ─────────────────────────────────────────────────────────

class _PriceRangeSlider extends StatelessWidget {
  final RangeValues priceRange;
  final bool isDark;
  final Color? bodyColor;
  final Color? mutedColor;
  final ValueChanged<RangeValues> onChanged;

  const _PriceRangeSlider({
    required this.priceRange,
    required this.isDark,
    required this.bodyColor,
    required this.mutedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : kLightGrey,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: label + live value range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'hotel_price_range'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: bodyColor,
                ),
              ),
              Text(
                '${CurrencyFormatter.format(priceRange.start)} – '
                '${CurrencyFormatter.format(priceRange.end)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: kBackgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: kBackgroundColor,
              inactiveTrackColor:
                  isDark ? Colors.grey[700] : Colors.grey[300],
              thumbColor: kBackgroundColor,
              overlayColor: kBackgroundColor.withValues(alpha: 0.12),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 3,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: RangeSlider(
              values: priceRange,
              min: 0,
              max: kHotelMaxPrice,
              divisions: 60,
              onChanged: onChanged,
            ),
          ),

          // Min / Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 EGP',
                style: TextStyle(fontSize: 10.sp, color: mutedColor),
              ),
              Text(
                CurrencyFormatter.format(kHotelMaxPrice),
                style: TextStyle(fontSize: 10.sp, color: mutedColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
