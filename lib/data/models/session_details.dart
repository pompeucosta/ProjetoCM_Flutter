import 'package:hive/hive.dart';

part 'session_details.g.dart';

@HiveType(typeId: 1)
class SessionDetails extends HiveObject {
  @HiveField(0)
  double averageSpeed = 0;
  @HiveField(1)
  double topSpeed = 0;
  @HiveField(2)
  int durationInSecods = 0;
  @HiveField(3)
  double distance = 0;
  @HiveField(4)
  int stepsTaken = 0;
  @HiveField(5)
  double caloriesBurned = 0;
  @HiveField(6)
  int day = 1;
  @HiveField(7)
  int month = 1;
  @HiveField(8)
  int year = 2023;
  @HiveField(9)
  String location = "";
  @HiveField(10)
  List<Map<String,dynamic>> coordinates = [];
  @HiveField(11)
  List<String> photos = [];

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
      this.location,
      this.coordinates,
      this.photos);
}
