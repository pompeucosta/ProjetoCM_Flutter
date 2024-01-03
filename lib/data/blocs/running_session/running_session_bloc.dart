import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:run_route/data/database/session_db.dart';
import 'package:run_route/data/models/preset.dart';
import 'package:run_route/data/models/session_details.dart';

import '../../../services/notification_controller.dart';

import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';

part 'running_session_event.dart';
part 'running_session_state.dart';

class RunningSessionBloc
    extends Bloc<RunningSessionEvent, RunningSessionState> {
  final SessionDatabase sessionDB;
  late Preset preset;
  StreamSubscription<int>? timer;
  int duration = 0;
  int initialStepValue = -1;

  bool isAllowedToSendNotification = false;
  bool timeWarned = false;
  bool distanceWarned = false;
  bool halfTimeWarned = false;
  bool halfDistanceWarned = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> close() async {
    timer?.cancel();
    final service = FlutterBackgroundService();
    if (await service.isRunning()) service.invoke("stopService");
    return super.close();
  }

  RunningSessionBloc(this.sessionDB) : super(const RunningSessionState()) {
    on<StartSessionEvent>((event, emit) async {
      try {
        isAllowedToSendNotification = await Permission.notification.isGranted;
        if (!isAllowedToSendNotification) {
          final status = await Permission.notification.request();
          isAllowedToSendNotification = status.isGranted;
        }
        preset = event.preset;
        final service = FlutterBackgroundService();
        if (isAllowedToSendNotification) {
          await service.startService();
        }
        emit(
            const RunningSessionState(status: RunningSessionStatus.inProgress));
        await timer?.cancel();
        timer =
            Stream.periodic(const Duration(seconds: 1), (elapsed) => elapsed)
                .listen((duration) {
          this.duration = duration;
          add(_TimerTicked(duration));
        });

        bool hasLocationPermission = await requestLocationPermissions();
        if (hasLocationPermission) {
            const LocationSettings locationSettings = LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 10,
            );
            StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
                (Position? position) {
                    
                    if (position != null && state.status == RunningSessionStatus.inProgress) {
                        add(_LocationReceived(position));
                    }
                });
        }

        PermissionStatus activityPermission = await Permission.activityRecognition.request();
        if (activityPermission.isGranted) {
          initialStepValue = -1;
          Stream<StepCount>_stepCountStream = await Pedometer.stepCountStream;
          _stepCountStream.listen((stepcount) => add(_StepDetected(stepcount.steps))).onError((object) =>  add(const _StepDetected(0)));
        }

        timeWarned = false;
        distanceWarned = false;
        halfTimeWarned = false;
        halfDistanceWarned = false;

      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<_TimerTicked>(((event, emit) async {
      final duration = Duration(seconds: event.durationInSeconds);
      final timerString =
          "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke(
          "update",
          {
            "content": "$timerString\n${NumberFormat("####0.0##").format(state.distance)} m",
          },
        );
      }
      emit(state.copyWith(durationInSeconds: event.durationInSeconds));
      if (!timeWarned &&
          isAllowedToSendNotification &&
          preset.durationInSeconds <= event.durationInSeconds) {
        timeWarned = true;
        // id 1 para o timer. usar outro id para notificacoes da distancia
        sendNotification("You have reached your time goal!", 1);
      }

      if (!halfTimeWarned &&
          isAllowedToSendNotification &&
          preset.twoWay &&
          preset.durationInSeconds / 2 <= event.durationInSeconds) {
        halfTimeWarned = true;
        // id 1 para o timer. usar outro id para notificacoes da distancia
        sendNotification(
            "You have reached half of your time goal!\nIt's time to go back.",
            1);
      }
    }));
    on<EndSessionEvent>((event, emit) async {
      try {
        final service = FlutterBackgroundService();
        if (await service.isRunning()) service.invoke("stopService");
        final today = DateTime.now();
        List<Map<String,dynamic>> coordinatesAsMapList = [];
        for (Position element in state.coordinates) {
          coordinatesAsMapList.add(element.toJson());
        }
        final details = SessionDetails(
            state.averageSpeed, state.topSpeed, duration, state.distance, state.stepsTaken, state.caloriesBurned, today.day, today.month, today.year, "", coordinatesAsMapList);

        await sessionDB.insertSession(details);
        emit(state.copyWith(status: RunningSessionStatus.ended));
        emit(state.copyWith(status: RunningSessionStatus.initial));
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<PauseUnpauseSessionEvent>((event, emit) {
      try {
        if (state.status == RunningSessionStatus.inProgress) {
          timer?.pause();
          emit(state.copyWith(status: RunningSessionStatus.paused));
        } else if (state.status == RunningSessionStatus.paused) {
          timer?.resume();
          emit(state.copyWith(status: RunningSessionStatus.inProgress));
        }
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<RestartSessionEvent>((event, emit) {
      //reset and call start session
      try {
        timer?.cancel();
        state.copyWith(
            status: RunningSessionStatus.initial,
            durationInSeconds: 0,
            stepsTaken: 0,
            averageSpeed: 0,
            topSpeed: 0,
            caloriesBurned: 0,
            distance: 0);
        add(StartSessionEvent(preset));
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<CancelSessionEvent>((event, emit) async {
      //stop timer and other services
      try {
        final service = FlutterBackgroundService();
        if (await service.isRunning()) service.invoke("stopService");
        timer?.cancel();
        emit(state.copyWith(status: RunningSessionStatus.success));
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<_LocationReceived>((event, emit) async {

        List<Position> coordinates = List<Position>.from(state.coordinates);
        double distance = state.distance;
        int time = state.durationInSeconds;
        double topSpeed = state.topSpeed;
        double calories = state.caloriesBurned;

        // update coordinates and distance
        if (coordinates.isNotEmpty) {
          Position? previous = coordinates.last;
          distance += Geolocator.distanceBetween(previous.latitude, previous.longitude, event.position.latitude, event.position.longitude);
        }
        coordinates.add(event.position);

        // update average speed
        double avgspeed = distance/(coordinates.last.timestamp.difference(coordinates.first.timestamp).inSeconds) * 0.36; //converting from m/s to km/h
        if (coordinates.length <= 1) {
          avgspeed = 0;
        }

        // update top speed
        if (event.position.speed * 0.36 > topSpeed && event.position.speedAccuracy < 10) {
          topSpeed = event.position.speed * 0.36;
        }
        if (avgspeed > topSpeed) {
          topSpeed = avgspeed;
        }

        // update calories
        double met = (1.350325 * avgspeed - 3.4510092).abs();
        if(avgspeed > 0.0){
            calories = time * met * 3.5 * 77 / (200 * 60) * 0.1;
        }


        emit(state.copyWith(distance: distance, coordinates: coordinates, averageSpeed: avgspeed, topSpeed: topSpeed, caloriesBurned: calories));
        
        if (!distanceWarned &&
          isAllowedToSendNotification &&
          preset.distance <= state.distance) {
        distanceWarned = true;
        // id 2 para a distancia
        sendNotification("You have reached your distance goal!", 2);
      }

      if (!halfDistanceWarned &&
          isAllowedToSendNotification &&
          preset.twoWay &&
          preset.distance / 2 <= state.distance) {
        halfDistanceWarned = true;
        // id 2 para a distancia
        sendNotification(
            "You have reached half of your distance goal!\nIt's time to go back.",
            2);
      }


    });
    on<_StepDetected>(((event, emit) async {
      if (initialStepValue < 0) {
        initialStepValue = event.stepCount;
      }
      int steps = event.stepCount - initialStepValue;
      if (steps < 0) {steps = 0;}

      emit(state.copyWith(stepsTaken: steps));
    }));
  }

  void sendNotification(String message, int notificationId) {
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'Session Goal',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChanngelsProperties.notificationsChannelKey,
          NotificationChanngelsProperties.notificationsChannelName,
          icon: 'ic_bg_service_small',
        ),
      ),
    );
  }

  Future<bool> requestLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return false;
      //return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
        //return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return false;
      //return Future.error(
      //  'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}
