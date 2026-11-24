import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/inspection_record.dart';
import '../services/inspection_service.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final InspectionService _inspectionService = InspectionService();

  List<InspectionRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    try {
      final records = await _inspectionService.getInspections();

      if (!mounted) return;

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar inspecciones: $error')),
      );
    }
  }

  Future<void> _deleteInspection(InspectionRecord record) async {
    try {
      await _inspectionService.deleteInspection(record.id);

      await _loadInspections();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspección eliminada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar inspección: $error')),
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final date = dateTime.toLocal();

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

  Widget _buildSensorValues(String title, dynamic sensor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text('X: ${sensor.x.toStringAsFixed(2)}'),
        Text('Y: ${sensor.y.toStringAsFixed(2)}'),
        Text('Z: ${sensor.z.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildInspectionCard(InspectionRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(record.imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inspección ${record.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 5),
            Text('Fecha: ${_formatDate(record.dateTime)}'),
            Text('Hora: ${_formatTime(record.dateTime)}'),
            const Divider(height: 24),
            _buildSensorValues('Acelerómetro', record.accelerometer),
            const SizedBox(height: 12),
            _buildSensorValues('Giroscopio', record.gyroscope),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _deleteInspection(record),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar inspección',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de inspecciones'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadInspections,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    'No hay inspecciones guardadas',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text('Toma una fotografía para crear una inspección'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInspections,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  return _buildInspectionCard(_records[index]);
                },
              ),
            ),
    );
  }
}
