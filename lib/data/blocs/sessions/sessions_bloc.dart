import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:run_route/data/models/session_details.dart';
import 'package:run_route/data/database/session_db.dart';

part 'sessions_event.dart';
part 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final SessionDatabase sessionDatabase;
  SessionsBloc(this.sessionDatabase) : super(const SessionsState()) {
    on<GetSessionsEvent>((event, emit) {
      final sessions = sessionDatabase.getAllSessionsFromMostRecentToOlder();
      emit(SessionsState(sessions: sessions));
    });
  }
}
