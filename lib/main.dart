import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';
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
      home: FadeInWrapper(child: GameScreen(initialDarkMode: initialDarkMode)),
    );
  }
}

class FadeInWrapper extends StatefulWidget {
  final Widget child;

  const FadeInWrapper({super.key, required this.child});

  @override
  State<FadeInWrapper> createState() => _FadeInWrapperState();
}

class _FadeInWrapperState extends State<FadeInWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    // Start the fade-in animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
