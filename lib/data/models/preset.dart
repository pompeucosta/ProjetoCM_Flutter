import 'package:hive/hive.dart';

part 'preset.g.dart';

@HiveType(typeId: 0)
class Preset extends HiveObject {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  bool twoWay = false;
  @HiveField(2)
  int durationInSeconds = 0;
  @HiveField(3)
  double distance = 1;
  Duration get duration => Duration(seconds: durationInSeconds);

  Preset({
    this.name = "",
    this.twoWay = false,
    this.durationInSeconds = 0,
    double? distance,
  }) {
    if (distance != null) {
      this.distance = distance;
    }
  }
}
