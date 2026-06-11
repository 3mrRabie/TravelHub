import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Hotel {
  final String name;
  final String bookingUrl;
  final String imageUrl;
  final double rating;
  final double latitude;
  final double longitude;

  Hotel({
    required this.name,
    required this.bookingUrl,
    required this.imageUrl,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'],
      bookingUrl: json['booking_url'],
      imageUrl: json['image_url'],
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class HotelService {
  static Future<List<Hotel>> loadHotelsFromAsset() async {
    final String jsonString = await rootBundle.loadString('assets/data/egypt_hotels_en.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> data = jsonData['hotels'];
    return data.map((e) => Hotel.fromJson(e)).toList();
  }
}
