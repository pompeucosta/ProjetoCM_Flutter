// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresetAdapter extends TypeAdapter<Preset> {
  @override
  final int typeId = 0;

  @override
  Preset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preset(
      fields[0] as String,
      fields[1] as bool,
      fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Preset obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.twoWay)
      ..writeByte(2)
      ..write(obj.durationInSecods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
