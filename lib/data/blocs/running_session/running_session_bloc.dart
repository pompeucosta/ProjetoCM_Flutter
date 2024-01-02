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

part 'running_session_event.dart';
part 'running_session_state.dart';

class RunningSessionBloc
    extends Bloc<RunningSessionEvent, RunningSessionState> {
  final SessionDatabase sessionDB;
  late Preset preset;
  StreamSubscription<int>? timer;
  int duration = 0;

  bool isAllowedToSendNotification = false;
  bool timeWarned = false;
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
            "content": "$timerString\n${state.distance} km",
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

      if (!timeWarned &&
          isAllowedToSendNotification &&
          preset.twoWay &&
          preset.durationInSeconds / 2 <= event.durationInSeconds) {
        timeWarned = true;
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
        final details = SessionDetails(
            0, 0, duration, 0, 0, 0, today.day, today.month, today.year, "");

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
        double avgspeed = distance/(coordinates.first.timestamp.difference(coordinates.last.timestamp).inSeconds) * 0.36; //converting from m/s to km/h
        if (coordinates.length <= 1) {
          avgspeed = 0;
        }

        // update top speed (uses average speeds to avoid spikes)
        double latestSpeed = avgspeed;
        if (coordinates.length == 2) {
          Position? pos1 = coordinates.last;
          Position? pos2 = coordinates.elementAt(coordinates.length-2);

          double tempDistance = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
          int tempTime = pos1.timestamp.difference(pos2.timestamp).inSeconds;
          latestSpeed = tempDistance/tempTime * 0.36;      
          
          
        }
        else if (coordinates.length == 3) {
          Position? pos1 = coordinates.last;
          Position? pos2 = coordinates.elementAt(coordinates.length-2);
          Position? pos3 = coordinates.elementAt(coordinates.length-3);

          double tempDistance1 = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
          int tempTime1 = pos1.timestamp.difference(pos2.timestamp).inSeconds;
            
          double tempDistance2 = Geolocator.distanceBetween(pos2.latitude, pos2.longitude, pos3.latitude, pos3.longitude);
          int tempTime2 = pos2.timestamp.difference(pos3.timestamp).inSeconds;
            
          latestSpeed = ((tempDistance1/tempTime1 * 0.36) + (tempDistance2/tempTime2 * 0.36))/2;      

        }
        else if (coordinates.length > 3) {
          Position? pos1 = coordinates.last;
          Position? pos2 = coordinates.elementAt(coordinates.length-2);
          Position? pos3 = coordinates.elementAt(coordinates.length-3);
          Position? pos4 = coordinates.elementAt(coordinates.length-4);

          double tempDistance1 = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
          int tempTime1 = pos1.timestamp.difference(pos2.timestamp).inSeconds;
            
          double tempDistance2 = Geolocator.distanceBetween(pos2.latitude, pos2.longitude, pos3.latitude, pos3.longitude);
          int tempTime2 = pos2.timestamp.difference(pos3.timestamp).inSeconds;

          double tempDistance3 = Geolocator.distanceBetween(pos3.latitude, pos3.longitude, pos4.latitude, pos4.longitude);
          int tempTime3 = pos3.timestamp.difference(pos4.timestamp).inSeconds;
          
          latestSpeed = ((tempDistance1/tempTime1 * 0.36) + (tempDistance2/tempTime2 * 0.36) + (tempDistance3/tempTime3 * 0.36))/3;

        }
        if (latestSpeed > topSpeed) {
          topSpeed = latestSpeed;
        }

        // update calories
        double met = (1.350325 * avgspeed - 3.4510092).abs();
        if(avgspeed > 0.0){
            calories = time * met * 3.5 * 77 / (200 * 60);
        }


        emit(state.copyWith(distance: distance, coordinates: coordinates, averageSpeed: avgspeed, topSpeed: topSpeed, caloriesBurned: calories));
        
    });
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
