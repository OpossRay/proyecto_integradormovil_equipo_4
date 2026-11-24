import 'package:sensors_plus/sensors_plus.dart';

import '../models/sensor_data.dart';

class SensorService {
  Stream<SensorData> getAccelerometerStream() {
    return accelerometerEventStream().map(
      (event) => SensorData(x: event.x, y: event.y, z: event.z),
    );
  }

  Stream<SensorData> getGyroscopeStream() {
    return gyroscopeEventStream().map(
      (event) => SensorData(x: event.x, y: event.y, z: event.z),
    );
  }
}
