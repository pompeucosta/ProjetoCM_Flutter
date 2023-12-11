import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'CameraPreviewScreen.dart';

class RunningSessionScreen extends StatefulWidget {
  const RunningSessionScreen({super.key});

  @override
  _RunningSessionScreenState createState() => _RunningSessionScreenState();
}

class _RunningSessionScreenState extends State<RunningSessionScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
              children: [
                  MyMap(),
                  DetailsContainer(),
                  ],
            ) ,
    );
  }
  
}


class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
@override
  Widget build(BuildContext context) {
    return Flexible(
      child: FlutterMap(
      options: MapOptions(
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
              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    )
  );
  }

}


class DetailsContainer extends StatefulWidget {
 const DetailsContainer({super.key});

 @override
  _DetailsContainerState createState() => _DetailsContainerState();
}

class _DetailsContainerState extends State<DetailsContainer> {

  final ExpansionTileController controller = ExpansionTileController();

  late DateTime sessionStartTime;

  @override
  void initState() {
    super.initState();
    sessionStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children:[
              ExpansionTile(
              initiallyExpanded: true,
              controller: controller,
              title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Session Details', style: Theme.of(context).textTheme.headlineSmall,)],),
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                       SessionDetails(sessionStartTime: sessionStartTime,),
                       Divider(),
                       SessionButtons(),
                    ],)
                ),
                ],
              ),
            ],
          );
  }
}

class SessionDetails extends StatefulWidget {
  const SessionDetails({super.key, required this.sessionStartTime});

  final DateTime sessionStartTime;

  @override
  _SessionDetailsState createState() => _SessionDetailsState();
}

class _SessionDetailsState extends State<SessionDetails> {

  

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
                  SessionInfo(name: "Time:", info: DurationDisplay(sessionStartTime: widget.sessionStartTime,),),
                  SessionInfo(name: "Average Speed:", info: Text("5 km/h", style: Theme.of(context).textTheme.headlineMedium,)),
                  SessionInfo(name: "Top Speed:", info: Text("12 km/h", style: Theme.of(context).textTheme.headlineMedium,)),
                ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SessionInfo(name: "Distance:", info: Text("3.082 km", style: Theme.of(context).textTheme.headlineMedium,)),
                  SessionInfo(name: "Steps Taken:", info: Text("3719", style: Theme.of(context).textTheme.headlineMedium,)),
                  SessionInfo(name: "Calories Burned:", info: Text("500 kcal", style: Theme.of(context).textTheme.headlineMedium,)),
                ],),
              ],
            );
  }
}


class SessionButtons extends StatefulWidget {
  const SessionButtons({super.key});

  @override
  _SessionButtonsState createState() => _SessionButtonsState();
}

class _SessionButtonsState extends State<SessionButtons> {

  void _goToCamera() {
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
                  padding: EdgeInsets.all(15),
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButton(text: "Pause", onPressed: (){}),
                        CustomButton(text: "Take Photo", onPressed: _goToCamera,)
                      ],
                    )
                ),
                Container(
                  padding: EdgeInsets.all(0),
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButton(text: "Cancel", onPressed: (){}),
                        CustomButton(text: "Finish", onPressed: (){}),
                    ],
                    )
                ),
              ],
            );
  }
}

class SessionInfo extends StatefulWidget {
  const SessionInfo({super.key, required this.name,  required this.info});

  final String name;
  final Widget info;

  @override
  _SessionInfoState createState() => _SessionInfoState();
}

class _SessionInfoState extends State<SessionInfo> {

  @override
  Widget build(BuildContext context) {
    return Container(
              padding: EdgeInsets.all(5),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: Theme.of(context).textTheme.headlineSmall,),
                widget.info,
              ],
            )
          );
  }

}

class CustomButton extends StatefulWidget {
  const CustomButton({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function() onPressed;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = TextButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary);

    return Container(width: 170,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child:ElevatedButton(
                      style: style,
                      onPressed: widget.onPressed,
                      child: Text(widget.text, style: Theme.of(context).textTheme.headlineSmall,)
                    )
                );
  }
}


class DurationDisplay extends StatefulWidget {
  const DurationDisplay({super.key, required this.sessionStartTime});

  final DateTime sessionStartTime;

  @override
  _DurationDisplayState createState() => _DurationDisplayState();
}

class _DurationDisplayState extends State<DurationDisplay> {

  late Timer timer;
  late Duration elapsedTime;

  @override
  void initState() {
    super.initState();
    elapsedTime = Duration.zero;

    // Create a timer that updates the UI every second
    timer = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
      setState(() {
        elapsedTime = DateTime.now().difference(widget.sessionStartTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
      return Text(elapsedTimeAsString(), style: Theme.of(context).textTheme.headlineMedium,);
  }

  String elapsedTimeAsString() {
    int hours = elapsedTime.inHours;
    int minutes = elapsedTime.inMinutes%60;
    int seconds = elapsedTime.inSeconds%60;


    return "${hours.toString().length == 1 ? '0${hours.toString()}' : hours.toString()}:${minutes.toString().length == 1 ? '0${minutes.toString()}' : minutes.toString()}:${seconds.toString().length == 1 ? '0${seconds.toString()}' : seconds.toString()}";
  }

}