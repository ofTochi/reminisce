// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleaning_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CleaningSessionAdapter extends TypeAdapter<CleaningSession> {
  @override
  final int typeId = 0;

  @override
  CleaningSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CleaningSession(
      sourceName: fields[0] as String,
      date: fields[1] as DateTime,
      filesDeleted: fields[2] as int,
      mbFreed: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CleaningSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sourceName)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.filesDeleted)
      ..writeByte(3)
      ..write(obj.mbFreed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CleaningSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
