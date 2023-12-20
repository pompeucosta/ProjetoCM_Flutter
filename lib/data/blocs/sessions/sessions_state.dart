part of 'sessions_bloc.dart';

final class SessionsState extends Equatable {
  const SessionsState({this.sessions = const []});
  final List<SessionDetails> sessions;

  @override
  List<Object> get props => [sessions];
}
