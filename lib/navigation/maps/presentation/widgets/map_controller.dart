import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_hub/navigation/maps/services/hotel_service.dart';
import 'package:travel_hub/navigation/maps/services/location_service.dart';

// Fallback centre (Cairo, Egypt) shown when location permission is denied
// or GPS is unavailable, so the map always loads instead of spinning forever.
const LatLng _kCairoCenter = LatLng(30.0444, 31.2357);

class FullMapController {
  final Completer<GoogleMapController> googleController = Completer();

  CameraPosition? cameraPosition;
  Marker? myMarker;
  Set<Marker> hotelMarkers = {};

  /// Non-null when we fell back to the default location.
  /// The UI can read this to show a permission-denied banner.
  String? locationError;

  // Cache the bitmap so we only render it once
  BitmapDescriptor? _cachedHotelIcon;

  Future<void> setInitialLocation(Function refreshUI) async {
    try {
      final Position pos = await LocationService.determinePosition();

      cameraPosition = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 13,
      );

      myMarker = Marker(
        markerId: const MarkerId("me"),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: const InfoWindow(title: "My Location"),
      );

      locationError = null;
    } catch (e) {
      // Location unavailable — fall back to Cairo so the map still loads.
      debugPrint('Location error: $e');
      locationError = e.toString();
      cameraPosition = const CameraPosition(target: _kCairoCenter, zoom: 12);
      myMarker = null; // no "me" marker when we don't know the real position
    }

    // Load hotel markers regardless of whether GPS succeeded.
    try {
      await _loadHotelMarkers(refreshUI);
    } catch (e) {
      debugPrint('Hotel markers error: $e');
    }

    refreshUI();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Custom marker rendering
  // ─────────────────────────────────────────────────────────────────────────

  /// Renders a small (44 dp) circular hotel marker at [pixelRatio] density.
  Future<BitmapDescriptor> _buildHotelMarker({double pixelRatio = 3.0}) async {
    if (_cachedHotelIcon != null) return _cachedHotelIcon!;

    const double logicalSize = 44.0;
    final double px = logicalSize * pixelRatio;
    final double r = px / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, px, px));

    // Drop-shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(r, r + 2), r - 4, shadowPaint);

    // Circle background (brand red)
    final bgPaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(Offset(r, r), r - 4, bgPaint);

    // White ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = px * 0.045;
    canvas.drawCircle(Offset(r, r), r - 4, ringPaint);

    // Hotel icon
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.hotel.codePoint),
      style: TextStyle(
        fontSize: px * 0.46,
        fontFamily: Icons.hotel.fontFamily,
        package: Icons.hotel.fontPackage,
        color: Colors.white,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(r - iconPainter.width / 2, r - iconPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(px.round(), px.round());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    _cachedHotelIcon = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: logicalSize,
      height: logicalSize,
    );
    return _cachedHotelIcon!;
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadHotelMarkers(Function refreshUI) async {
    final List<Hotel> hotels = await HotelService.loadHotelsFromAsset();
    final BitmapDescriptor icon = await _buildHotelMarker(pixelRatio: 3.0);

    final Set<Marker> markers = {};
    for (final hotel in hotels) {
      markers.add(
        Marker(
          markerId: MarkerId(hotel.name),
          position: LatLng(hotel.latitude, hotel.longitude),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: hotel.name,
            snippet: '⭐ ${hotel.rating}',
          ),
        ),
      );
    }

    hotelMarkers = markers;
    refreshUI();
  }

  Future<void> goToMyLocation(Function refreshUI) async {
    try {
      final Position pos = await LocationService.determinePosition();
      final controller = await googleController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (e) {
      debugPrint('goToMyLocation error: $e');
    }
  }

  Future<LatLng?> searchLocation(String query) async {
    if (query.isEmpty) return null;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (e) {
      debugPrint('Search error: $e');
      return null;
    }
  }
}
