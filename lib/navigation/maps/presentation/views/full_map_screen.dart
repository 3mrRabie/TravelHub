import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/maps/presentation/widgets/map_controller.dart';

class FullMapScreen extends StatefulWidget {
  final LatLng? targetLocation;
  final String? targetName;

  const FullMapScreen({super.key, this.targetLocation, this.targetName});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final FullMapController mapController = FullMapController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mapController.setInitialLocation(() => setState(() {}));

   
    if (widget.targetLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final controller = await mapController.googleController.future;

        controller.animateCamera(
          CameraUpdate.newLatLngZoom(widget.targetLocation!, 15),
        );

        mapController.myMarker = Marker(
          markerId: const MarkerId("search_result"),
          position: widget.targetLocation!,
          infoWindow: InfoWindow(title: widget.targetName),
        );

        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mapController.cameraPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: mapController.cameraPosition!,
                  myLocationEnabled: true,
                  onMapCreated: (c) => mapController.googleController.complete(c),
                  markers: {
                    if (mapController.myMarker != null) mapController.myMarker!,
                    ...mapController.hotelMarkers,
                  },
                ),

        
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) async {
                  final result = await mapController.searchLocation(val.trim());
                  if (result != null) {
                    final google = await mapController.googleController.future;
                    google.animateCamera(CameraUpdate.newLatLngZoom(result, 15));
                    mapController.myMarker = Marker(
                      markerId: const MarkerId("search_result"),
                      position: result,
                      infoWindow: InfoWindow(title: val.trim()),
                    );
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final result = await mapController.searchLocation(searchController.text.trim());
                      if (result != null) {
                        final google = await mapController.googleController.future;
                        google.animateCamera(CameraUpdate.newLatLngZoom(result, 15));
                        mapController.myMarker = Marker(
                          markerId: const MarkerId("search_result"),
                          position: result,
                          infoWindow: InfoWindow(title: searchController.text.trim()),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: () => mapController.goToMyLocation(() => setState(() {})),
              heroTag: "locationBtn",
              backgroundColor: kBackgroundColor,
              foregroundColor: kWhite,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
