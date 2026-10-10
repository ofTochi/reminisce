// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_session_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedSessionStateAdapter extends TypeAdapter<SavedSessionState> {
  @override
  final int typeId = 1;

  @override
  SavedSessionState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedSessionState(
      sourceType: fields[0] as String,
      sourceName: fields[1] as String,
      sourcePath: fields[2] as String,
      contentType: fields[3] as int,
      currentIndex: fields[4] as int,
      markedFilePaths: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedSessionState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sourceType)
      ..writeByte(1)
      ..write(obj.sourceName)
      ..writeByte(2)
      ..write(obj.sourcePath)
      ..writeByte(3)
      ..write(obj.contentType)
      ..writeByte(4)
      ..write(obj.currentIndex)
      ..writeByte(5)
      ..write(obj.markedFilePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedSessionStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
