part of 'sessions_bloc.dart';

sealed class SessionsEvent extends Equatable {
  const SessionsEvent();
}

final class GetSessionsEvent extends SessionsEvent {
  const GetSessionsEvent();

  @override
  List<Object?> get props => [];
}
