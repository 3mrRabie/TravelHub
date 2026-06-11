import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';

class LandMarkFavoritesRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  LandMarkFavoritesRepository({
    required this.firestore,
    required this.auth,
  });

  String get uid => auth.currentUser!.uid;

  String _safeId(LandMark landMark) {
    final raw = "${landMark.name}_${landMark.location}";
    return md5.convert(utf8.encode(raw)).toString();
  }

  CollectionReference get _favRef =>
      firestore.collection("users").doc(uid).collection("landmark_favorites");

  Future<void> addFavorite(LandMark landMark) async {
    await _favRef.doc(_safeId(landMark)).set(landMark.toJson());
  }

  Future<void> removeFavorite(LandMark landMark) async {
    await _favRef.doc(_safeId(landMark)).delete();
  }

  Future<List<LandMark>> loadFavorites() async {
    final snapshot = await _favRef.get();
    return snapshot.docs
        .map((doc) => LandMark.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearFavorites() async {
    final docs = await _favRef.get();
    for (var d in docs.docs) {
      await d.reference.delete();
    }
  }
}
