import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_route/data/blocs/running_session/running_session_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CameraPreviewScreen.dart';

class RunningSessionScreen extends StatelessWidget {
  const RunningSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RunningSessionView(),
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Session Details',
                style: Theme.of(context).textTheme.headlineSmall,
              )
            ],
          ),
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    SessionDetails(state),
                    const Divider(),
                    const SessionButtons(),
                  ],
                )),
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
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
  const SessionButtons({super.key});

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
        Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomButton(text: "Pause", onPressed: () {}),
                CustomButton(
                  text: "Take Photo",
                  onPressed: () {
                    _goToCamera(context);
                  },
                )
              ],
            )),
        Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomButton(text: "Cancel", onPressed: () {}),
                CustomButton(text: "Finish", onPressed: () {}),
              ],
            )),
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              info,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ));
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary);

    return Container(
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: ElevatedButton(
            style: style,
            onPressed: onPressed,
            child: Text(
              text,
              style: Theme.of(context).textTheme.headlineSmall,
            )));
  }
}
