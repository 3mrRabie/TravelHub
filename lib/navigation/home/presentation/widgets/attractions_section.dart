import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/maps/presentation/views/full_map_screen.dart';
import 'package:travel_hub/navigation/maps/services/location_service.dart';

// Fallback centre (Cairo, Egypt) — shown when location permission is denied
// or GPS is unavailable, so the map always loads instead of spinning forever.
const LatLng _kCairoFallback = LatLng(30.0444, 31.2357);

class AttractionsSection extends StatefulWidget {
  const AttractionsSection({super.key});

  @override
  State<AttractionsSection> createState() => _AttractionsSectionState();
}

class _AttractionsSectionState extends State<AttractionsSection> {
  LatLng? _location;
  String? _locationError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      // Uses LocationService which handles: permission request, GPS check,
      // and a 10-second timeout — same as the full map screen.
      final pos = await LocationService.determinePosition();
      if (!mounted) return;
      setState(() {
        _location = LatLng(pos.latitude, pos.longitude);
        _locationError = null;
        _loading = false;
      });
    } catch (e) {
      // Permission denied or GPS unavailable → fall back to Cairo.
      if (!mounted) return;
      setState(() {
        _location = _kCairoFallback;
        _locationError = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nearby Hotels".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FullMapScreen(),
                  ),
                );
              },
              child: Text(
                "View Full Map".tr(),
                style: TextStyle(
                  color: kBackgroundColor,
                  decoration: TextDecoration.underline,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── Map container ───────────────────────────────────────────────────
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: kLightBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: _buildMapContent(),
          ),
        ),

        // ── Location-denied hint ─────────────────────────────────────────────
        if (!_loading && _locationError != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Row(
              children: [
                Icon(Icons.location_off, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "location_fallback_note".tr(),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildMapContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // _location is always non-null here (either real or fallback)
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _location!,
        zoom: 14,
      ),
      markers: {
        if (_locationError == null)
          Marker(
            markerId: const MarkerId('me'),
            position: _location!,
            infoWindow: InfoWindow(title: "My Location".tr()),
          ),
      },
      myLocationEnabled: _locationError == null,
      zoomControlsEnabled: false,
      liteModeEnabled: true,
      onMapCreated: (_) {},
    );
  }
}
