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

final class PauseSessionEvent extends RunningSessionEvent {
  const PauseSessionEvent();

  @override
  List<Object?> get props => [];
}

final class UnPauseSessionEvent extends RunningSessionEvent {
  const UnPauseSessionEvent();

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
