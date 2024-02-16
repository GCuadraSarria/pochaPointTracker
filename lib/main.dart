import 'package:firebase_core/firebase_core.dart';
import 'package:pocha_points_tracker/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:provider/provider.dart';

import 'pages/pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrentPlayers(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          displayLarge: TextStyle(fontFamily: 'Roboto'),
        ),
      ),

      home: const HomePage(),
      // home: const WinnerGameplayPage(),
    );
  }
}
