import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:run_route/data/database/running_session_db.dart';
import 'package:run_route/data/models/preset.dart';
import 'package:run_route/data/models/session_details.dart';

part 'running_session_event.dart';
part 'running_session_state.dart';

class RunningSessionBloc
    extends Bloc<RunningSessionEvent, RunningSessionState> {
  final RunningSessionDatabase sessionDB;
  late Preset preset;
  StreamSubscription<int>? timer;
  int duration = 0;

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  RunningSessionBloc(this.sessionDB) : super(const RunningSessionState()) {
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
    on<PauseSessionEvent>((event, emit) {
      try {
        if (state.status == RunningSessionStatus.inProgress) {
          timer?.pause();
          emit(state.copyWith(status: RunningSessionStatus.paused));
        }
      } catch (err) {
        emit(state.copyWith(status: RunningSessionStatus.failure));
      }
    });
    on<UnPauseSessionEvent>((event, emit) {
      try {
        if (state.status == RunningSessionStatus.paused) {
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
}
