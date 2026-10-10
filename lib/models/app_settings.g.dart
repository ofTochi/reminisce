// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      deletionLimit: fields[0] as int,
      defaultSwipeIsDelete: fields[1] as bool,
      autoPlayVideos: fields[2] as bool,
      showFileSizes: fields[3] as bool,
      notifWeeklyDigest: fields[4] as bool,
      notifGroupNudge: fields[5] as bool,
      notifPostClean: fields[6] as bool,
      fitContent: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.deletionLimit)
      ..writeByte(1)
      ..write(obj.defaultSwipeIsDelete)
      ..writeByte(2)
      ..write(obj.autoPlayVideos)
      ..writeByte(3)
      ..write(obj.showFileSizes)
      ..writeByte(4)
      ..write(obj.notifWeeklyDigest)
      ..writeByte(5)
      ..write(obj.notifGroupNudge)
      ..writeByte(6)
      ..write(obj.notifPostClean)
      ..writeByte(7)
      ..write(obj.fitContent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
