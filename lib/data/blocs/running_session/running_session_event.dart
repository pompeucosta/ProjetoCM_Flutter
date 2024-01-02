part of 'running_session_bloc.dart';

sealed class RunningSessionEvent extends Equatable {
  const RunningSessionEvent();
}

final class StartSessionEvent extends RunningSessionEvent {
  final Preset preset;
  const StartSessionEvent(this.preset);

  @override
  List<Object?> get props => [preset];
}

final class EndSessionEvent extends RunningSessionEvent {
  const EndSessionEvent();

  @override
  List<Object?> get props => [];
}

final class PauseUnpauseSessionEvent extends RunningSessionEvent {
  const PauseUnpauseSessionEvent();

  @override
  List<Object?> get props => [];
}

final class RestartSessionEvent extends RunningSessionEvent {
  const RestartSessionEvent();

  @override
  List<Object?> get props => [];
}

final class CancelSessionEvent extends RunningSessionEvent {
  const CancelSessionEvent();

  @override
  List<Object?> get props => [];
}

final class _TimerTicked extends RunningSessionEvent {
  const _TimerTicked(this.durationInSeconds);
  final int durationInSeconds;

  @override
  List<Object?> get props => [durationInSeconds];
}

final class _LocationReceived extends RunningSessionEvent {
  const _LocationReceived(this.position);
  final Position position;

  @override
  List<Object?> get props => [position];
}