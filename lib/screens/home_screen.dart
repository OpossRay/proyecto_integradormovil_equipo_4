import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../models/point_of_interest.dart';

import 'package:url_launcher/url_launcher.dart';

import '../services/point_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final PointStorageService _storageService = PointStorageService();
  final List<PointOfInterest> _points = [];

  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedPoints();
  }

  Future<void> _loadSavedPoints() async {
    try {
      final savedPoints = await _storageService.loadPoints();

      if (!mounted) return;

      setState(() {
        _points
          ..clear()
          ..addAll(savedPoints);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudieron cargar los puntos: $error';
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePoint() async {
    if (_currentPosition == null) return;

    String enteredName = '';

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo punto de interés'),
        content: TextField(
          autofocus: true,
          onChanged: (value) {
            enteredName = value;
          },
          decoration: const InputDecoration(
            labelText: 'Nombre del lugar',
            hintText: 'Ej. Mi escuela',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, enteredName);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted || name == null || name.trim().isEmpty) {
      return;
    }

    final position = _currentPosition!;

    final newPoint = PointOfInterest(
      name: name.trim(),
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState(() {
      _points.add(newPoint);
    });

    try {
      await _storageService.savePoints(_points);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Punto guardado correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el punto: $error')),
      );
    }
  }

  double _calculateDistance(PointOfInterest point) {
    if (_currentPosition == null) return 0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      point.latitude,
      point.longitude,
    );
  }

  Future<void> _openMap(PointOfInterest point) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );

    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi ubicación GPS'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on, size: 90, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Geolocalización',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Obtén las coordenadas actuales de tu dispositivo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: _isLoading ? null : _getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Obtener mi ubicación'),
              ),

              const SizedBox(height: 24),

              if (_isLoading) const Center(child: CircularProgressIndicator()),

              if (_errorMessage != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              if (_currentPosition != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación obtenida',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text('Latitud: ${_currentPosition!.latitude}'),
                        const SizedBox(height: 10),
                        Text('Longitud: ${_currentPosition!.longitude}'),
                        const SizedBox(height: 10),
                        Text('Precisión: ${_currentPosition!.accuracy} metros'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _savePoint,
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Guardar como punto de interés'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                'Mis puntos de interés',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (_points.isEmpty)
                const Text('Todavía no tienes puntos guardados.'),

              ..._points.map(
                (point) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(point.name),
                    subtitle: Text(
                      'Latitud: ${point.latitude}\n'
                      'Longitud: ${point.longitude}\n'
                      'Distancia: ${_currentPosition == null ? "Obtén tu ubicación para calcularla" : "${_calculateDistance(point).toStringAsFixed(2)} metros"}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      tooltip: 'Abrir en Google Maps',
                      onPressed: () => _openMap(point),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
