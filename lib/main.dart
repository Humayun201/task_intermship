import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aetting.dart';
import 'home page.dart';
import 'on board screen.dart';


void main() {
  runApp(CleverTypeApp());
}

class CleverTypeApp extends StatelessWidget {
  // Getters for app configuration
  String get appTitle => 'CleverType AI Keyboard';

  Color get primaryBackgroundColor => Color(0xFF1a1a2e);
  Color get secondaryBackgroundColor => Color(0xFF16213e);
  Color get cardBackgroundColor => Color(0xFF0f3460);
  Color get primaryColor => Colors.purple;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: primaryBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: secondaryBackgroundColor,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: cardBackgroundColor,
          elevation: 4,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Getters for splash screen configuration
  String get appName => 'CleverType';
  String get loadingText => 'AI Writing Assistant';
  IconData get splashIcon => Icons.auto_fix_high;
  Color get iconColor => Colors.purple;
  Color get textColor => Colors.white;
  int get splashDuration => 1500; // milliseconds

  @override
  void initState() {
    super.initState();
    _checkFirstTimeAndNavigate();
  }

  Future<void> _checkFirstTimeAndNavigate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('first_time') ?? true;

      // Add splash delay
      await Future.delayed(Duration(milliseconds: splashDuration));

      if (isFirstTime) {
        // First time opening the app, show onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // Not first time, go directly to home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // If there's an error, default to showing onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  splashIcon,
                  size: 50,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 30),
              Text(
                appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                loadingText,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to easily navigate between screens
extension NavigationHelper on BuildContext {
  void navigateToSettings() {
    Navigator.pushNamed(this, '/settings');
  }

  void navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(this, '/home', (route) => false);
  }

  void navigateToOnboarding() {
    Navigator.pushNamedAndRemoveUntil(this, '/onboarding', (route) => false);
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
