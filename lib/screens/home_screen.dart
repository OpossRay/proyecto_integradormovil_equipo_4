import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../models/inspection_record.dart';
import '../models/sensor_data.dart';
import '../services/inspection_service.dart';
import '../services/photo_service.dart';
import '../services/sensor_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final InspectionService _inspectionService = InspectionService();
  final PhotoService _photoService = PhotoService();
  final SensorService _sensorService = SensorService();

  XFile? _selectedImage;
  bool _isSaving = false;

  Future<SensorData> _getCurrentSensorValue(Stream<SensorData> stream) async {
    return await stream.first.timeout(const Duration(seconds: 5));
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (!mounted || photo == null) return;

      setState(() {
        _selectedImage = photo;
        _isSaving = true;
      });

      final savedImagePath = await _photoService.savePhoto(photo.path);

      final accelerometer = await _getCurrentSensorValue(
        _sensorService.getAccelerometerStream(),
      );

      final gyroscope = await _getCurrentSensorValue(
        _sensorService.getGyroscopeStream(),
      );

      final record = InspectionRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: savedImagePath,
        dateTime: DateTime.now(),
        accelerometer: accelerometer,
        gyroscope: gyroscope,
      );

      await _inspectionService.saveInspection(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Inspección guardada correctamente!')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la inspección: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Práctica 09 - Multimedia y sensores'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 70, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Captura de fotografías',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 90, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _isSaving ? 'Guardando inspección...' : 'Tomar fotografía',
                ),
              ),
              if (_selectedImage != null)
                TextButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar fotografía'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
