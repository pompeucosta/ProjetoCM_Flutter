import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:run_route/data/database/session_db.dart';
import 'package:run_route/data/models/preset.dart';
import 'package:run_route/data/models/session_details.dart';
import 'package:run_route/services/notification_controller.dart';

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

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  RunningSessionBloc(this.sessionDB) : super(const RunningSessionState()) {
    AwesomeNotifications().isNotificationAllowed().then((value) {
      isAllowedToSendNotification = value;
      if (!isAllowedToSendNotification) {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((value) => isAllowedToSendNotification = value);
      }
    });

    // AwesomeNotifications().setListeners(
    //     onActionReceivedMethod: NotificationController.onActionReceivedMethod);
    on<StartSessionEvent>((event, emit) async {
      try {
        preset = event.preset;
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
    on<_TimerTicked>(((event, emit) {
      emit(state.copyWith(durationInSeconds: event.durationInSeconds));
      if (!timeWarned &&
          isAllowedToSendNotification &&
          preset.durationInSeconds <= event.durationInSeconds) {
        timeWarned = true;
        sendNotification("You have reached your time goal!");
      }

      if (!timeWarned &&
          isAllowedToSendNotification &&
          preset.twoWay &&
          preset.durationInSeconds / 2 <= event.durationInSeconds) {
        timeWarned = true;
        sendNotification(
            "You have reached half of your time goal!\nIt's time to go back.");
      }
    }));
    on<EndSessionEvent>((event, emit) async {
      try {
        final today = DateTime.now();
        final details = SessionDetails(
            0, 0, duration, 0, 0, 0, today.day, today.month, today.year, "");

        await sessionDB.insertSession(details);
        emit(state.copyWith(status: RunningSessionStatus.success));
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
    on<CancelSessionEvent>((event, emit) {
      //stop timer and other services
      try {
        timer?.cancel();
        emit(state.copyWith(status: RunningSessionStatus.success));
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
  }

  void sendNotification(String message) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: NotificationChanngelsProperties.notificationsChannelKey,
      title: "Goal",
      body: message,
      notificationLayout: NotificationLayout.BigText,
    ));
  }
}
