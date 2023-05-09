// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SensorAdapter extends TypeAdapter<Sensor> {
  @override
  final int typeId = 0;

  @override
  Sensor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sensor(
      address: fields[0] as String,
      date: fields[1] as String,
      id: fields[2] as int,
      type: fields[3] as String,
      value: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Sensor obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
