import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_route/data/blocs/sessions/sessions_bloc.dart';
import 'package:run_route/data/models/session_details.dart';
import 'package:run_route/main.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
      body: HistorySession(session),
    );
  }
}

class HistorySession extends StatelessWidget {
  const HistorySession(this.session, {super.key});
  final SessionDetails session;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          DateDisplay(session.day, session.month, session.year),
          MyMap_History(session),
          DetailsContainer_History(session), 
      ],
      );
  }
}


class MyMap_History extends StatelessWidget {
  final SessionDetails state;
  const MyMap_History(this.state, {super.key});

  @override
  Widget build(BuildContext context) {

    MapController mapControl = MapController();
    const Color mapLinesColor = Color.fromARGB(255, 2, 2, 69);

    LatLng currentPosition = const LatLng(40.63311541916194, -8.659546357913722);
    List<LatLng> coordinatesAsLatLng = <LatLng>[];
    if (state.coordinates.isNotEmpty) {
      Position lastPosition = Position.fromMap(state.coordinates.last);
      currentPosition = LatLng(lastPosition.latitude, lastPosition.longitude); 
      for (Map<String, dynamic> element in state.coordinates) {
        Position elem = Position.fromMap(element);
        coordinatesAsLatLng.add(LatLng(elem.latitude, elem.longitude));
      }
    }
    else
    {
      coordinatesAsLatLng.add(currentPosition);
    }
    

    return Flexible(
        child: FlutterMap(
              mapController: mapControl,
              options: MapOptions(
                initialCenter: currentPosition,
                initialZoom: 9.2,
                onMapReady: () => mapControl.fitCamera(CameraFit.coordinates(coordinates: coordinatesAsLatLng, maxZoom: 17, padding: const EdgeInsets.all(50))),
              ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(polylines: [Polyline(points: coordinatesAsLatLng, color: mapLinesColor, strokeWidth: 5)]),
        MarkerLayer(
          markers: [
            Marker(
              point: coordinatesAsLatLng.first,
              width: 10,
              height: 10,
              child: const Icon(Icons.circle, color: mapLinesColor, size: 10,),
            ),
            Marker(
              point: coordinatesAsLatLng.last,
              width: 10,
              height: 10,
              child: const Icon(Icons.run_circle_outlined, color: mapLinesColor, size: 10,),
            ),
          ],
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
        Container(
          alignment: Alignment.bottomLeft,
          child: IconButton.filled(
                alignment: Alignment.bottomLeft,
                iconSize: 30,
                icon: const Icon(Icons.my_location),
                color: Colors.white,
                onPressed: () =>
                  mapControl.fitCamera(CameraFit.coordinates(coordinates: coordinatesAsLatLng, maxZoom: 17, padding: const EdgeInsets.all(50)))
                ))
      ],
    ));
  }
}



class DetailsContainer_History extends StatelessWidget {
  DetailsContainer_History(this.state, {super.key});
  final ExpansionTileController controller = ExpansionTileController();
  final DateTime sessionStartTime = DateTime.now();
  final SessionDetails state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: ExpansionTile(
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
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 150),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                    child: SessionDetails_History(state),
                  ),
                  const Divider(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      child: Text("View photos"),
                      onPressed: () async {
                        Directory mainDirectory = await getApplicationDocumentsDirectory();
                        DateTime startTime = Position.fromMap(state.coordinates.first).timestamp;
                        DateTime endTime = Position.fromMap(state.coordinates.last).timestamp;

                        await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PhotoGallery_History(startTime: startTime, endTime: endTime, imagesDirectoryPath: "${mainDirectory.path}"),
                                  ),
                                );
                      },
                    ),
                  ),
                ],
              )
            )
          ],
        ),
    )],
    );
  }
}

class SessionDetails_History extends StatelessWidget {
  final SessionDetails state;
  const SessionDetails_History(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    NumberFormat distanceFormat = NumberFormat("####0.0##");
    NumberFormat speedFormat = NumberFormat("####0.0");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionInfo_History(
              name: "Time:",
              info:
                  "${state.duration.inHours.toString().padLeft(2, '0')}:${(state.duration.inMinutes % 60).toString().padLeft(2, '0')}:${(state.duration.inSeconds % 60).toString().padLeft(2, '0')}",
            ),
            SessionInfo_History(
              name: "Average Speed:",
              info: "${speedFormat.format(state.averageSpeed)} km/h",
            ),
            SessionInfo_History(
              name: "Top Speed:",
              info: "${speedFormat.format(state.topSpeed)} km/h",
            ),
          ],
        ),
         Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionInfo_History(
              name: "Distance:",
              info: state.distance>1000? "${distanceFormat.format(state.distance/1000)} km" : "${distanceFormat.format(state.distance)} m",
            ),
            SessionInfo_History(
              name: "Steps Taken:",
              info: "${state.stepsTaken}",
            ),
            SessionInfo_History(
              name: "Calories Burned:",
              info: state.caloriesBurned>1? "${distanceFormat.format(state.caloriesBurned/1000)} kcal" : "${distanceFormat.format(state.caloriesBurned)} cal" ,
            ),
          ],
        ),
      ],
    );
  }
}

class SessionInfo_History extends StatelessWidget {
  const SessionInfo_History({super.key, required this.name, required this.info});

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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ));
  }
}



class PhotoGallery_History extends StatelessWidget {
  const PhotoGallery_History({super.key, required this.imagesDirectoryPath, required this.startTime, required this.endTime});

  final DateTime startTime;
  final DateTime endTime;
  final String imagesDirectoryPath;

  List<Widget> getPhotos(BuildContext context) {
    List<Container> photos = [];

    Directory imagesDir = Directory(imagesDirectoryPath);

    List contents = imagesDir.listSync(recursive: true);
    for (var fileOrDir in contents) {
      if (fileOrDir is File) {
        String filePath = fileOrDir.path;
        print("Image found: ${filePath}");
        if (filePath.contains('${imagesDirectoryPath}RunRoute_')) {
          filePath.replaceFirst('${imagesDirectoryPath}RunRoute_', '');
          filePath.replaceFirst('.jpg', '');
          int timestamp = int.parse(filePath);

          if (DateTime.fromMillisecondsSinceEpoch(timestamp).isAfter(startTime) || DateTime.fromMillisecondsSinceEpoch(timestamp).isBefore(endTime)) {
            Image img = Image.file(File(fileOrDir.path));
            photos.add(Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height, maxWidth: MediaQuery.of(context).size.width),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: img.image,)
                        ),
            ));
          }
        }
      }
    }

    if (photos.isEmpty) {
      photos.add(Container(
        alignment: Alignment.center,
        child: Text("No photos found")
      ));
    }
    return photos;
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Container(child: Text("Aveiro - Portugal"), alignment: Alignment.centerRight,),),
      body: Center(
        child: PageView(
          children: getPhotos(context),)
      ),
    );
  }
}


