import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:run_route/SessionInProgress.dart';
import 'package:run_route/data/blocs/home/bottom_navigation_bloc.dart';
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
                RunningSessionBloc(context.read<RunningSessionDatabase>())),
        BlocProvider(create: (context) => BottomNavigationBloc()),
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
      body: const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Welcome to RunRoute")]),
      ),
    );
  }
}
