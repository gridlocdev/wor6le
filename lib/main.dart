import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get system brightness to use as default if no user preference exists
  final systemBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  // Load theme preference before showing any UI
  final storage = StorageService();
  final themeModeString = await storage.getThemeMode();

  // Resolve dark mode based on theme mode setting
  final darkMode = _resolveDarkModeFromThemeString(
    themeModeString,
    systemBrightness,
  );

  // Set the system UI overlay style to match the theme
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
    ),
  );
  usePathUrlStrategy();
  runApp(MyApp(initialDarkMode: darkMode));
}

bool _resolveDarkModeFromThemeString(
  String themeMode,
  Brightness systemBrightness,
) {
  switch (themeMode) {
    case 'light':
      return false;
    case 'dark':
      return true;
    case 'system':
    default:
      return systemBrightness == Brightness.dark;
  }
}

class MyApp extends StatelessWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wor6le',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.getBackgroundColor(initialDarkMode),
      ),
      home: GameScreen(initialDarkMode: initialDarkMode),
    );
  }
}
