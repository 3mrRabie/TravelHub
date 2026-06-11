class Hotels {
  final String name;
  final String city;
  final String bookingUrl;
  final String imageUrl;
  final double rating;
  final String description;
  final int reviewsCount;
  final int stars;
  final String lastUpdated;
  final double pricePerNight;
  final double latitude;
  final double longitude;
  final List<String> facilities;

  Hotels({
    required this.name,
    required this.city,
    required this.bookingUrl,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.reviewsCount,
    required this.stars,
    required this.lastUpdated,
    required this.pricePerNight,
    required this.latitude,
    required this.longitude,
    required this.facilities,
  });

  factory Hotels.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rooms = json['rooms'] ?? [];
    double extractedPrice = 0.0;

    if (rooms.isNotEmpty) {
      final firstRoom = rooms.first;
      extractedPrice = (firstRoom['price_egp_per_night'] ?? 0).toDouble();
    }

    return Hotels(
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      bookingUrl: json['booking_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      reviewsCount: json['reviews_count'] ?? 0,
      stars: json['stars'] ?? 0,
      lastUpdated: json['last_updated'] ?? '',
      pricePerNight: extractedPrice,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      facilities: List<String>.from(json['facilities'] ?? []),
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'booking_url': bookingUrl,
      'image_url': imageUrl,
      'rating': rating,
      'description': description,
      'reviews_count': reviewsCount,
      'stars': stars,
      'last_updated': lastUpdated,
      'price_per_night': pricePerNight,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities,
    };
  }
}
