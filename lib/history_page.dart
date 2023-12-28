import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_route/data/blocs/sessions/sessions_bloc.dart';
import 'package:run_route/data/models/session_details.dart';
import 'package:run_route/main.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionsBloc, SessionsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("History")),
          ),
          body: HistoryList(state.sessions),
        );
      },
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList(this.sessions, {super.key});
  final List<SessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final session = sessions[index];
        return TextButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return HistorySessionInfo(session);
                },
              ));
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.all(0.0),
            ),
            child: Card(
              child: ListTile(
                title: Text("${session.day}-${session.month}-${session.year}"),
                subtitle: Text(
                  "${session.duration.inHours.toString().padLeft(2, '0')}:${(session.duration.inMinutes % 60).toString().padLeft(2, '0')}:${(session.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                ),
                trailing: Text(session.location),
              ),
            ));
      },
      itemCount: sessions.length,
    );
  }
}

class HistorySessionInfo extends StatelessWidget {
  const HistorySessionInfo(this.session, {super.key});
  final SessionDetails session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Session"))),
      body: SingleChildScrollView(child: Session(session)),
    );
  }
}
