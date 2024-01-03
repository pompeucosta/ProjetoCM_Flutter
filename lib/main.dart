import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:run_route/session_in_progress.dart';
import 'package:run_route/data/blocs/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:run_route/data/blocs/sessions/sessions_bloc.dart';
import 'package:run_route/data/database/presets_db.dart';
import 'package:run_route/data/database/session_db.dart';
import 'package:run_route/data/models/session_details.dart' as session_model;
import 'package:run_route/history_page.dart';
import 'package:run_route/services/notification_controller.dart';

import 'data/blocs/presets/presets_bloc.dart';
import 'data/blocs/running_session/running_session_bloc.dart';
import 'presets_page.dart';

import 'package:camera/camera.dart';
import 'data/blocs/camera_cubit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'data/blocs/map_controller_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AndroidNotificationChannel foreground = AndroidNotificationChannel(
    NotificationChanngelsProperties.foregroundServiceChannelKey,
    NotificationChanngelsProperties.foregroundServiceChannelName,
    description:
        NotificationChanngelsProperties.foregroundServiceChannelDescription,
    importance: Importance.low,
  );

  AndroidNotificationChannel notifications = AndroidNotificationChannel(
    NotificationChanngelsProperties.notificationsChannelKey,
    NotificationChanngelsProperties.notificationsChannelName,
    description:
        NotificationChanngelsProperties.notificationsChannelDescription,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final plugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await plugin?.createNotificationChannel(foreground);
  await plugin?.createNotificationChannel(notifications);

  await initializeService();

  await Hive.initFlutter();
  final PresetsDatabase presetsdb = PresetsDatabase();
  await presetsdb.init();

  final SessionDatabase sessiondb = SessionDatabase();
  await sessiondb.init();

  final cameras = await availableCameras();
  final camera = cameras.first;

  runApp(MyApp(presetsdb, sessiondb, camera));
}

class MyApp extends StatelessWidget {
  final PresetsDatabase presetsdb;
  final SessionDatabase sessiondb;
  final CameraDescription camera;
  const MyApp(this.presetsdb, this.sessiondb, this.camera, {super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF1456fc);
    const Color secondarySeedColor = Color(0xFF4614fc);
    const Color tertiarySeedColor = Color(0xFF14cafc);

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
        home: Providers(camera, MapController()),
      ),
    );
  }
}

class Providers extends StatelessWidget {
  final CameraDescription camera;
  final MapController mapControl; 
  const Providers(this.camera, this.mapControl, {super.key});

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
            create: (context) => SessionsBloc(context.read<SessionDatabase>())
              ..add(const GetSessionsEvent())),
        BlocProvider(create: (context) => CameraCubit(camera)),
        BlocProvider(create: (context) => MapControllerCubit(mapControl)),

      ],
      child: SafeArea(
        child: HomePage(),
      ),
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
    const BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: "History",
    ),
  ];

  final BottomNavigationBarItem sessionPage =
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: "Session");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
        builder: (context, state) {
      return Scaffold(
        body: buildBody(state.selectedTab),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: state.selectedTab.index,
          items: state.includeSession ? (pages + [sessionPage]) : pages,
          onTap: (value) {
            context.read<BottomNavigationBloc>().add(TabChangedEvent(value));
          },
          selectedItemColor: Colors.blue[500],
          unselectedItemColor: Colors.blue[200],
        ),
      );
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
        return const HistoryPage();
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
                  : HistorySession(state.sessions.first);
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
        child: Column(
      children: [
        Text("Welcome to Run Route!"),
        Text("Try creating a preset and start running."),
      ],
    ));
  }
}

class Session extends StatelessWidget {
  const Session(this.session, {super.key});
  final session_model.SessionDetails session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateDisplay(session.day, session.month, session.year),
        DetailsContainer(session),
      ],
    );
  }
}

class DateDisplay extends StatelessWidget {
  const DateDisplay(this.day, this.month, this.year, {super.key});
  final int year;
  final int month;
  final int day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Session of $day-$month-$year"),
    );
  }
}

class DetailsContainer extends StatelessWidget {
  DetailsContainer(this.state, {super.key});
  final ExpansionTileController controller = ExpansionTileController();
  final DateTime sessionStartTime = DateTime.now();
  final session_model.SessionDetails state;

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
          children: [
            SessionDetailsScreen(state),
          ],
        )
      ],
    );
  }
}

class SessionDetailsScreen extends StatelessWidget {
  final session_model.SessionDetails state;
  const SessionDetailsScreen(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
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
