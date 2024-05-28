import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/routes.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initUxCam() {
    if (kIsWeb) return;
    FlutterUxcam
        .optIntoSchematicRecordings(); // Confirm that you have user permission for screen recording
    FlutterUxConfig config = FlutterUxConfig(
      userAppKey: AppEnvironment.uxCamKey,
      enableAutomaticScreenNameTagging: false,
    );
    FlutterUxcam.startWithConfiguration(config);
  }

  @override
  Widget build(BuildContext context) {
    initUxCam();
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'ZipBuzz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white.withOpacity(0.7),
          selectionHandleColor: AppColors.borderGrey,
          selectionColor: AppColors.primaryColor.withOpacity(0.1),
        ),
      ),
      initialRoute: AuthGate.id,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
