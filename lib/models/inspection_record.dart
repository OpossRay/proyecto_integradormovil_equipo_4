import 'sensor_data.dart';

class InspectionRecord {
  final String id;
  final String imagePath;
  final DateTime dateTime;
  final SensorData accelerometer;
  final SensorData gyroscope;

  const InspectionRecord({
    required this.id,
    required this.imagePath,
    required this.dateTime,
    required this.accelerometer,
    required this.gyroscope,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'accelerometer': {
        'x': accelerometer.x,
        'y': accelerometer.y,
        'z': accelerometer.z,
      },
      'gyroscope': {'x': gyroscope.x, 'y': gyroscope.y, 'z': gyroscope.z},
    };
  }

  factory InspectionRecord.fromJson(Map<String, dynamic> json) {
    return InspectionRecord(
      id: json['id'],
      imagePath: json['imagePath'],
      dateTime: DateTime.parse(json['dateTime']),
      accelerometer: SensorData(
        x: (json['accelerometer']['x'] as num).toDouble(),
        y: (json['accelerometer']['y'] as num).toDouble(),
        z: (json['accelerometer']['z'] as num).toDouble(),
      ),
      gyroscope: SensorData(
        x: (json['gyroscope']['x'] as num).toDouble(),
        y: (json['gyroscope']['y'] as num).toDouble(),
        z: (json['gyroscope']['z'] as num).toDouble(),
      ),
    );
  }
}
