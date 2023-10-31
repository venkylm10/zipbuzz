import 'package:flutter/material.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/pages/home/home.dart';
import 'package:zipbuzz/pages/home/home_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZipBuzz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white.withOpacity(0.7),
          selectionHandleColor: Colors.white,
          selectionColor: Colors.white.withOpacity(0.4),
        ),
      ),
      home: const Home(),
    );
  }
}
