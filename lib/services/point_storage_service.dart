import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/point_of_interest.dart';

class PointStorageService {
  static const String _storageKey = 'saved_points';

  // Guardar los puntos de interés.
  Future<void> savePoints(List<PointOfInterest> points) async {
    final preferences = await SharedPreferences.getInstance();

    final pointsJson = points.map((point) => point.toJson()).toList();

    await preferences.setString(_storageKey, jsonEncode(pointsJson));
  }

  // Recuperar los puntos guardados.
  Future<List<PointOfInterest>> loadPoints() async {
    final preferences = await SharedPreferences.getInstance();

    final savedData = preferences.getString(_storageKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return PointOfInterest.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  // Eliminar todos los puntos guardados.
  Future<void> clearPoints() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
