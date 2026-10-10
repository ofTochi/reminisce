import 'package:hive/hive.dart';

part 'cleaning_session.g.dart';

@HiveType(typeId: 0)
class CleaningSession {
  @HiveField(0)
  final String sourceName;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final int filesDeleted;
  @HiveField(3)
  final double mbFreed;

  CleaningSession({
    required this.sourceName,
    required this.date,
    required this.filesDeleted,
    required this.mbFreed,
  });
}
