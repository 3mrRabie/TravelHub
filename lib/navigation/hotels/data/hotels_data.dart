import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';

class EgHotels {
  static Future<List<Hotels>> getEgHotels(String lang) async {
    final response = await rootBundle.loadString(
      "assets/data/egypt_hotels_$lang.json",
    );
    final decoded = jsonDecode(response);
    final List hotels = decoded["hotels"];
    final shuffled = hotels..shuffle();
    return shuffled.map((e) => Hotels.fromJson(e)).toList();
  }
}


