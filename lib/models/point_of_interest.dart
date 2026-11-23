class PointOfInterest {
  final String name;
  final double latitude;
  final double longitude;

  const PointOfInterest({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Convertir el punto de interés a JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'latitude': latitude, 'longitude': longitude};
  }

  // Recuperar un punto de interés desde JSON
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
