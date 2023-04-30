class Sensor {
  final String address;
  final String date;
  final int id;
  final String type;
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
