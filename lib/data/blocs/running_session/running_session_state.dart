part of 'running_session_bloc.dart';

enum RunningSessionStatus {
  initial,
  paused,
  inProgress,
  success,
  failure,
  ended
}

final class RunningSessionState extends Equatable {
  final RunningSessionStatus status;
  final int durationInSeconds;
  final int stepsTaken;
  final double averageSpeed;
  final double topSpeed;
  final double caloriesBurned;
  final double distance;
  final List<Position> coordinates;
  final List<String> photos;

  Duration get duration => Duration(seconds: durationInSeconds);

  const RunningSessionState(
      {this.status = RunningSessionStatus.initial,
      this.averageSpeed = 0.0,
      this.caloriesBurned = 0.0,
      this.durationInSeconds = 0,
      this.stepsTaken = 0,
      this.topSpeed = 0.0,
      this.distance = 0.0,
      this.coordinates = const <Position>[],
      this.photos = const <String>[]  });

  RunningSessionState copyWith(
      {RunningSessionStatus? status,
      int? durationInSeconds,
      int? stepsTaken,
      double? averageSpeed,
      double? topSpeed,
      double? caloriesBurned,
      double? distance,
      List<Position>? coordinates,
      List<String>? photos}) {
    return RunningSessionState(
        status: status ?? this.status,
        durationInSeconds: durationInSeconds ?? this.durationInSeconds,
        stepsTaken: stepsTaken ?? this.stepsTaken,
        averageSpeed: averageSpeed ?? this.averageSpeed,
        topSpeed: topSpeed ?? this.topSpeed,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
        distance: distance ?? this.distance,
        coordinates: coordinates ?? this.coordinates,
        photos: photos ?? this.photos);
  }

  @override
  List<Object> get props => [
        status,
        durationInSeconds,
        stepsTaken,
        averageSpeed,
        topSpeed,
        caloriesBurned,
        distance,
        coordinates,
        photos
      ];
}
