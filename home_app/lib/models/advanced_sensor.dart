import 'package:hive/hive.dart';
part 'advanced_sensor.g.dart';

@HiveType(typeId: 1)
class AdvancedSensor {
  @HiveField(0)
  final String ip;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String endpoints;

  @HiveField(3)
  final String date;

  const AdvancedSensor({
    required this.ip,
    required this.name,
    required this.endpoints,
    required this.date,
  });

  factory AdvancedSensor.fromJson(Map<String, dynamic> json) {
    return AdvancedSensor(
      ip: json['ip'],
      name: json['name'],
      endpoints: json['endpoints'],
      date: json['date'],
    );
  }

  @override
  String toString() {
    return 'AdvancedSensor{address: $ip, name: $name, endpoints: $endpoints, date: $date}';
  }
}
