// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionDetailsAdapter extends TypeAdapter<SessionDetails> {
  @override
  final int typeId = 1;

  @override
  SessionDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionDetails(
      fields[0] as int,
      fields[1] as int,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as int,
      fields[6] as int,
      fields[7] as int,
      fields[8] as int,
      fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SessionDetails obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.averageSpeed)
      ..writeByte(1)
      ..write(obj.topSpeed)
      ..writeByte(2)
      ..write(obj.durationInSecods)
      ..writeByte(3)
      ..write(obj.distance)
      ..writeByte(4)
      ..write(obj.stepsTaken)
      ..writeByte(5)
      ..write(obj.caloriesBurned)
      ..writeByte(6)
      ..write(obj.day)
      ..writeByte(7)
      ..write(obj.month)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
