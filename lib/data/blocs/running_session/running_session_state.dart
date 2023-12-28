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
  final int averageSpeed;
  final int topSpeed;
  final int caloriesBurned;
  final int distance;

  Duration get duration => Duration(seconds: durationInSeconds);

  const RunningSessionState(
      {this.status = RunningSessionStatus.initial,
      this.averageSpeed = 0,
      this.caloriesBurned = 0,
      this.durationInSeconds = 0,
      this.stepsTaken = 0,
      this.topSpeed = 0,
      this.distance = 0});

  RunningSessionState copyWith(
      {RunningSessionStatus? status,
      int? durationInSeconds,
      int? stepsTaken,
      int? averageSpeed,
      int? topSpeed,
      int? caloriesBurned,
      int? distance}) {
    return RunningSessionState(
        status: status ?? this.status,
        durationInSeconds: durationInSeconds ?? this.durationInSeconds,
        stepsTaken: stepsTaken ?? this.stepsTaken,
        averageSpeed: averageSpeed ?? this.averageSpeed,
        topSpeed: topSpeed ?? this.topSpeed,
        caloriesBurned: caloriesBurned ?? this.caloriesBurned,
        distance: distance ?? this.distance);
  }

  @override
  List<Object> get props => [
        status,
        durationInSeconds,
        stepsTaken,
        averageSpeed,
        topSpeed,
        caloriesBurned,
        distance
      ];
}
