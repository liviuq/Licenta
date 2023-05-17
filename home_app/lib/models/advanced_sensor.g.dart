// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_sensor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvancedSensorAdapter extends TypeAdapter<AdvancedSensor> {
  @override
  final int typeId = 1;

  @override
  AdvancedSensor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvancedSensor(
      ip: fields[0] as String,
      name: fields[1] as String,
      endpoints: fields[2] as String,
      date: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdvancedSensor obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ip)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.endpoints)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvancedSensorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
