import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/maps/presentation/views/full_map_screen.dart';

class AttractionsSection extends StatefulWidget {
  const AttractionsSection({super.key});

  @override
  State<AttractionsSection> createState() => _AttractionsSectionState();
}

class _AttractionsSectionState extends State<AttractionsSection> {
  LatLng? currentLocation;
  Marker? myMarker;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      myMarker = Marker(
        markerId: const MarkerId('me'),
        position: currentLocation!,
        infoWindow: const InfoWindow(title: "My Location"),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nearby Attractions".tr(),
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
        SizedBox(height: 20.h),
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: kLightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 14,
                    ),
                    markers: {if (myMarker != null) myMarker!},
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    liteModeEnabled: true,
                    onMapCreated: (controller) => mapController = controller,
                  ),
                ),
        ),
      ],
    );
  }
}
