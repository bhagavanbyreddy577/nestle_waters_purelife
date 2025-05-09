import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget { // Changed to StatelessWidget
  const SplashScreen({super.key});

  Future<void> _checkFirstLaunch(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      // If it's the first launch, go to the intro screen
      Future.delayed(Duration(seconds: 2), () { // Simulate a splash screen delay
        context.go('/intro');
      });
      await prefs.setBool('isFirstLaunch', false); // Set the flag
    } else {
      // If it's not the first launch, go to the main screen
      Future.delayed(Duration(seconds: 2), () { // Simulate a splash screen delay
        context.go('/temp');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call _navigateToMainScreen directly within the build method
    _checkFirstLaunch(context); // Navigate

    // Build the splash screen UI
    return Scaffold(
      backgroundColor: Colors.blue, // Set the background color of the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // You can add your logo or any other widget here
            const FlutterLogo(size: 100), // Example: Flutter logo
            const SizedBox(height: 20),
            const Text(
              'Welcome to My App', // Example: App name or slogan
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}