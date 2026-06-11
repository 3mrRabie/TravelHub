import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';

class FavoritesRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoritesRepository({
    required this.firestore,
    required this.auth,
  });

  String get uid => auth.currentUser!.uid;

  String _safeId(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  CollectionReference get _favRef =>
      firestore.collection("users").doc(uid).collection("favorites");

  Future<void> addFavorite(Hotels hotel) async {
    await _favRef.doc(_safeId(hotel.bookingUrl)).set(hotel.toJson());
  }

  Future<void> removeFavorite(String bookingUrl) async {
    await _favRef.doc(_safeId(bookingUrl)).delete();
  }

  Future<List<Hotels>> loadFavorites() async {
    final snapshot = await _favRef.get();
    return snapshot.docs
        .map((doc) => Hotels.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearFavorites() async {
    final docs = await _favRef.get();
    for (var d in docs.docs) {
      await d.reference.delete();
    }
  }
}
