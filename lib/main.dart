import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_route/SessionInProgress.dart';
import 'package:run_route/data/blocs/home/bottom_navigation_bloc.dart';
import 'package:run_route/data/blocs/sessions/sessions_bloc.dart';
import 'package:run_route/data/database/presets_db.dart';
import 'package:run_route/data/database/session_db.dart';
import 'package:run_route/data/models/session_details.dart' as SessionModel;
import 'package:url_launcher/url_launcher.dart';

import 'data/blocs/presets/presets_bloc.dart';
import 'data/blocs/running_session/running_session_bloc.dart';
import 'presets_page.dart';

void main() async {
  await Hive.initFlutter();
  final PresetsDatabase presetsdb = PresetsDatabase();
  await presetsdb.init();

  final SessionDatabase sessiondb = SessionDatabase();
  await sessiondb.init();

  runApp(MyApp(presetsdb, sessiondb));
}

class MyApp extends StatelessWidget {
  final PresetsDatabase presetsdb;
  final SessionDatabase sessiondb;
  const MyApp(this.presetsdb, this.sessiondb, {super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF6750A4);
    const Color secondarySeedColor = Color(0xFF3871BB);
    const Color tertiarySeedColor = Color(0xFF6CA450);

    final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: primarySeedColor,
      secondaryKey: secondarySeedColor,
      tertiaryKey: tertiarySeedColor,
      tones: FlexTones.vivid(Brightness.light),
    );

    final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: primarySeedColor,
      secondaryKey: secondarySeedColor,
      tertiaryKey: tertiarySeedColor,
      tones: FlexTones.vivid(Brightness.dark),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => presetsdb),
        RepositoryProvider(create: (context) => sessiondb),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RunRoute',
        themeMode: ThemeMode.system,
        theme: ThemeData.from(
          colorScheme: schemeLight,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.from(
          colorScheme: schemeDark,
          useMaterial3: true,
        ),
        home: const Providers(),
      ),
    );
  }
}

class Providers extends StatelessWidget {
  const Providers({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PresetsBloc(context.read<PresetsDatabase>()),
        ),
        BlocProvider(
            create: (context) =>
                RunningSessionBloc(context.read<SessionDatabase>())),
        BlocProvider(create: (context) => BottomNavigationBloc()),
        BlocProvider(
            create: (context) => SessionsBloc(context.read<SessionDatabase>()))
      ],
      child: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<BottomNavigationBarItem> pages = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: "Presets",
    ),
  ];

  final BottomNavigationBarItem sessionPage =
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: "Session");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
        builder: (context, state) {
      return LayoutBuilder(builder: (context, constrainsts) {
        return Scaffold(
          body: buildBody(state.selectedTab),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.selectedTab.index,
            items: state.includeSession ? (pages + [sessionPage]) : pages,
            onTap: (value) {
              context.read<BottomNavigationBloc>().add(TabChangedEvent(value));
            },
          ),
        );
      });
    });
  }

  Widget buildBody(AppTab selectedTab) {
    switch (selectedTab) {
      case AppTab.home:
        return const GreetingsPage();
      case AppTab.presets:
        return const PresetsPage();
      case AppTab.session:
        return const RunningSessionScreen();
      case AppTab.history:
        return const Placeholder();
    }
  }

  int tabToIndex(AppTab selectedTab) {
    switch (selectedTab) {
      case AppTab.home:
        return 0;
      case AppTab.presets:
        return 1;
      case AppTab.session:
        return 2;
      case AppTab.history:
        return 0;
    }
  }
}

class GreetingsPage extends StatelessWidget {
  const GreetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Welcome")),
      ),
      body: Center(
        child: BlocBuilder<SessionsBloc, SessionsState>(
          builder: (context, state) {
            return state.sessions.isEmpty
                ? const NoSession()
                : Column(
                    children: [
                      const MyMap(),
                      DetailsContainer(state.sessions.first)
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class NoSession extends StatelessWidget {
  const NoSession({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
            "Welcome to Run Route!\nTry creating a preset and start running."));
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
  final SessionModel.SessionDetails state;

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
                    SessionDetailsScreen(state),
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

class SessionDetailsScreen extends StatelessWidget {
  final SessionModel.SessionDetails state;
  const SessionDetailsScreen(this.state, {super.key});

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
