import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_themes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize(); // AJOUTER CETTE LIGNE
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentTheme = 'Deku';
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final theme = prefs.getString('user_theme') ?? 'Deku';

    setState(() {
      _userId = userId;
      _currentTheme = theme;
      _isLoading = false;
    });
  }

  void _updateTheme(String theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Life Manager',
      theme: AppThemes.themes[_currentTheme] ?? AppThemes.dekuTheme,
      debugShowCheckedModeBanner: false,
      home: _userId != null 
          ? HomeScreen(userId: _userId!, onThemeChanged: _updateTheme)
          : LoginScreen(onThemeChanged: _updateTheme),
    );
  }
}
