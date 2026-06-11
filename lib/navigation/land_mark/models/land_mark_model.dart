class LandMark {
  final String name;
  final String location;
  final String shortInfo;
  final String detailedInfo;
  final String mainImage;
  final List<String> galleryImages;

  LandMark({
    required this.name,
    required this.location,
    required this.shortInfo,
    required this.detailedInfo,
    required this.mainImage,
    required this.galleryImages,
  });

  factory LandMark.fromJson(Map<String, dynamic> json) {
    return LandMark(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      shortInfo: json['shortInfo'] ?? '',
      detailedInfo: json['detailedInfo'] ?? '',
      mainImage: json['mainImage'] ?? '',
      galleryImages: json['galleryImages'] != null
          ? List<String>.from(json['galleryImages'])
          : [],
    );
  }
   Map<String, dynamic> toJson() {
    return {
      "name": name,
      "location": location,
      "shortInfo": shortInfo,
      "detailedInfo": detailedInfo,
      "mainImage": mainImage,
      "galleryImages": galleryImages,
    };
  }
}
