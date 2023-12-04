import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:run_route/data/preset.dart';

import 'presets_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Preset>(PresetAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF6750A4);
    const Color secondarySeedColor = Color(0xFF3871BB);
    const Color tertiarySeedColor = Color(0xFF6CA450);

    final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      // Primary key color is required, like seed color ColorScheme.fromSeed.
      primaryKey: primarySeedColor,
      // You can add optional own seeds for secondary and tertiary key colors.
      secondaryKey: secondarySeedColor,
      tertiaryKey: tertiarySeedColor,
      // Tone chroma config and tone mapping is optional, if you do not add it
      // you get the config matching Flutter's Material 3 ColorScheme.fromSeed.
      tones: FlexTones.vivid(Brightness.light),
    );

    final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: primarySeedColor,
      secondaryKey: secondarySeedColor,
      tertiaryKey: tertiarySeedColor,
      tones: FlexTones.vivid(Brightness.dark),
    );

    return MaterialApp(
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
      home: const MyHomePage(),
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
    PresetsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: pages[selectedIndex], //pages[selectedIndex],
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
