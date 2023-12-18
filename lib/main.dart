import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:run_route/SessionInProgress.dart';
import 'package:run_route/data/database/presets_db.dart';
import 'package:run_route/data/database/running_session_db.dart';

import 'data/blocs/presets/presets_bloc.dart';
import 'data/blocs/running_session/running_session_bloc.dart';
import 'presets_page.dart';

void main() async {
  await Hive.initFlutter();
  final PresetsDatabase presetsdb = PresetsDatabase();
  await presetsdb.init();

  final RunningSessionDatabase sessiondb = RunningSessionDatabase();
  await sessiondb.init();

  runApp(MyApp(presetsdb, sessiondb));
}

class MyApp extends StatelessWidget {
  final PresetsDatabase presetsdb;
  final RunningSessionDatabase sessiondb;
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
        home: const TestPage(),
      ),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PresetsBloc(context.read<PresetsDatabase>()),
        ),
        BlocProvider(
            create: (context) =>
                RunningSessionBloc(context.read<RunningSessionDatabase>())),
      ],
      child: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  final List<Widget> pages = [
    const GreetingsPage(),
    const PresetsPage(),
    const RunningSessionView(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: "Presets",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: "Session",
              ),
            ]),
      );
    });
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
      body: const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Welcome to RunRoute")]),
      ),
    );
  }
}
