import 'package:assignment_1/camera_screen.dart';

import 'package:flutter/material.dart';

// The main function, the entry point of the Flutter app
void main() {
  // Runs the app by calling the MyApp widget
  runApp(const MyApp());
}

// MyApp is a stateless widget that serves as the root of the application
class MyApp extends StatelessWidget {
  // Constructor with a key parameter
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Returns a MaterialApp widget, which provides many basic app features
    return MaterialApp(
      // The title of the app, displayed in the task switcher
      title: 'Flutter Demo',

      // Defines the app's theme
      theme: ThemeData(
        // Creates a color scheme based on a seed color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Enables Material 3 design features
        useMaterial3: true,
      ),

      // Sets the home page of the app to the CameraScreen widget
      home: const CameraScreen(),
    );
  }
}
