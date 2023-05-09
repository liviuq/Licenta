import 'package:hive/hive.dart';
part 'sensor.g.dart';

@HiveType(typeId: 0)
class Sensor {
  @HiveField(0)
  final String address;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final int id;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final int value;

  const Sensor({
    required this.address,
    required this.date,
    required this.id,
    required this.type,
    required this.value,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      address: json['address'],
      date: json['date'],
      id: json['id'],
      type: json['type'],
      value: json['value'],
    );
  }

  @override
  String toString() {
    return 'Sensor{address: $address, date: $date, id: $id, type: $type, value: $value}';
  }
}
