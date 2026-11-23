import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    // 1. Comprobar si el GPS está activado.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('El GPS está desactivado.');
    }

    // 2. Consultar los permisos actuales.
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. Solicitar permiso si todavía no está concedido.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 4. Comprobar si el usuario rechazó el permiso.
    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }

    // 5. Comprobar si el permiso fue denegado permanentemente.
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'El permiso fue denegado permanentemente. '
        'Actívalo desde los ajustes de la aplicación.',
      );
    }

    // 6. Obtener la ubicación actual.
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
