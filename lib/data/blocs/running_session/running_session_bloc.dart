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
}
