import 'package:hive/hive.dart';

part 'preset.g.dart';

@HiveType(typeId: 0)
class Preset extends HiveObject {
  @HiveField(0)
  String name = "";
  @HiveField(1)
  bool twoWay = false;
  @HiveField(2)
  int durationInSecods = 0;
  Duration get duration => Duration(seconds: durationInSecods);

  Preset(this.name, this.twoWay, this.durationInSecods);
}
