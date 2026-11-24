import 'package:material_ui/material_ui.dart';

import '../models/sensor_data.dart';
import '../services/sensor_service.dart';

class SensorsScreen extends StatelessWidget {
  SensorsScreen({super.key});

  final SensorService _sensorService = SensorService();

  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required Stream<SensorData> stream,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            StreamBuilder<SensorData>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error al leer el sensor');
                }

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;

                return Column(
                  children: [
                    Text('X: ${data.x.toStringAsFixed(2)}'),
                    Text('Y: ${data.y.toStringAsFixed(2)}'),
                    Text('Z: ${data.z.toStringAsFixed(2)}'),
                  ],
                );
              },
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
        title: const Text('Sensores de movimiento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSensorCard(
              title: 'Acelerómetro',
              icon: Icons.speed,
              stream: _sensorService.getAccelerometerStream(),
            ),
            _buildSensorCard(
              title: 'Giroscopio',
              icon: Icons.screen_rotation,
              stream: _sensorService.getGyroscopeStream(),
            ),
          ],
        ),
      ),
    );
  }
}
