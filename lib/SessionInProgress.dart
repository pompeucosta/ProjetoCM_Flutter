import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_route/data/blocs/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:run_route/data/blocs/running_session/running_session_bloc.dart';
import 'package:run_route/data/blocs/sessions/sessions_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CameraPreviewScreen.dart';

class RunningSessionScreen extends StatelessWidget {
  const RunningSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(child: RunningSessionView()),
    );
  }
}

class RunningSessionView extends StatelessWidget {
  const RunningSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RunningSessionBloc, RunningSessionState>(
        listener: (context, state) {
      switch (state.status) {
        case RunningSessionStatus.failure:
          break;
        case RunningSessionStatus.inProgress:
          break;
        case RunningSessionStatus.initial:
          break;
        case RunningSessionStatus.paused:
          break;
        case RunningSessionStatus.success:
          break;
      }
    }, builder: (context, state) {
      return Column(
        children: [
          // const MyMap(),
          DetailsContainer(state),
        ],
      );
    }, buildWhen: (previous, current) {
      return current.status == RunningSessionStatus.inProgress ||
          current.status == RunningSessionStatus.paused;
    });
  }
}

class MyMap extends StatelessWidget {
  const MyMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(40.63311541916194, -8.659546357913722),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    ));
  }
}

class DetailsContainer extends StatelessWidget {
  DetailsContainer(this.state, {super.key});
  final ExpansionTileController controller = ExpansionTileController();
  final DateTime sessionStartTime = DateTime.now();
  final RunningSessionState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          controller: controller,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Session Details',
              )
            ],
          ),
          children: [
            Column(
              children: [
                SessionDetails(state),
                const Divider(),
                SessionButtons(state.status),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SessionDetails extends StatelessWidget {
  final RunningSessionState state;
  const SessionDetails(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionInfo(
              name: "Time:",
              info:
                  "${state.duration.inHours.toString().padLeft(2, '0')}:${(state.duration.inMinutes % 60).toString().padLeft(2, '0')}:${(state.duration.inSeconds % 60).toString().padLeft(2, '0')}",
            ),
            SessionInfo(
              name: "Average Speed:",
              info: "${state.averageSpeed}",
            ),
            SessionInfo(
              name: "Top Speed:",
              info: "${state.topSpeed}",
            ),
            SessionInfo(
              name: "Distance:",
              info: "${state.distance}",
            ),
            SessionInfo(
              name: "Steps Taken:",
              info: "${state.stepsTaken}",
            ),
            SessionInfo(
              name: "Calories Burned:",
              info: "${state.caloriesBurned}",
            ),
          ],
        ),
      ],
    );
  }
}

class SessionButtons extends StatelessWidget {
  const SessionButtons(this.sessionStatus, {super.key});
  final RunningSessionStatus sessionStatus;

  void _goToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  context
                      .read<RunningSessionBloc>()
                      .add(const PauseUnpauseSessionEvent());
                },
                icon: sessionStatus == RunningSessionStatus.inProgress
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow)),
            IconButton(
                onPressed: () {
                  _goToCamera(context);
                },
                icon: const Icon(Icons.camera_alt))
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  context
                      .read<RunningSessionBloc>()
                      .add(const CancelSessionEvent());

                  context
                      .read<BottomNavigationBloc>()
                      .add(const SessionEndedEvent());
                }),
            TextButton(
                child: const Text("Finish"),
                onPressed: () {
                  context
                      .read<RunningSessionBloc>()
                      .add(const EndSessionEvent());

                  //update history and home pages
                  context.read<SessionsBloc>().add(const GetSessionsEvent());

                  context
                      .read<BottomNavigationBloc>()
                      .add(const SessionEndedEvent());
                }),
          ],
        ),
      ],
    );
  }
}

class SessionInfo extends StatelessWidget {
  const SessionInfo({super.key, required this.name, required this.info});

  final String name;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
            ),
            Text(
              info,
            ),
          ],
        ));
  }
}
