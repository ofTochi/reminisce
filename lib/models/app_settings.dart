import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings {
  @HiveField(0)
  final int deletionLimit;
  @HiveField(1)
  final bool defaultSwipeIsDelete;
  @HiveField(2)
  final bool autoPlayVideos;
  @HiveField(3)
  final bool showFileSizes;
  @HiveField(4)
  final bool notifWeeklyDigest;
  @HiveField(5)
  final bool notifGroupNudge;
  @HiveField(6)
  final bool notifPostClean;
  @HiveField(7)
  final bool fitContent;

  AppSettings({
    this.deletionLimit = 50,
    this.defaultSwipeIsDelete = true,
    this.autoPlayVideos = true,
    this.showFileSizes = true,
    this.notifWeeklyDigest = true,
    this.notifGroupNudge = true,
    this.notifPostClean = true,
    this.fitContent = false,
  });

  AppSettings copyWith({
    int? deletionLimit,
    bool? defaultSwipeIsDelete,
    bool? autoPlayVideos,
    bool? showFileSizes,
    bool? notifWeeklyDigest,
    bool? notifGroupNudge,
    bool? notifPostClean,
    bool? fitContent,
  }) {
    return AppSettings(
      deletionLimit: deletionLimit ?? this.deletionLimit,
      defaultSwipeIsDelete: defaultSwipeIsDelete ?? this.defaultSwipeIsDelete,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      showFileSizes: showFileSizes ?? this.showFileSizes,
      notifWeeklyDigest: notifWeeklyDigest ?? this.notifWeeklyDigest,
      notifGroupNudge: notifGroupNudge ?? this.notifGroupNudge,
      notifPostClean: notifPostClean ?? this.notifPostClean,
      fitContent: fitContent ?? this.fitContent,
    );
  }
}
