import 'package:hive/hive.dart';

part 'session_details.g.dart';

@HiveType(typeId: 1)
class SessionDetails extends HiveObject {
  @HiveField(0)
  int averageSpeed = 0;
  @HiveField(1)
  int topSpeed = 0;
  @HiveField(2)
  int durationInSecods = 0;
  @HiveField(3)
  int distance = 0;
  @HiveField(4)
  int stepsTaken = 0;
  @HiveField(5)
  int caloriesBurned = 0;
  @HiveField(6)
  int day = 1;
  @HiveField(7)
  int month = 1;
  @HiveField(8)
  int year = 2023;
  @HiveField(9)
  String location = "";

  Duration get duration => Duration(seconds: durationInSecods);

  SessionDetails(
      this.averageSpeed,
      this.topSpeed,
      this.durationInSecods,
      this.distance,
      this.stepsTaken,
      this.caloriesBurned,
      this.day,
      this.month,
      this.year,
      this.location);
}
