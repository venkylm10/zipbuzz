import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/services/noti_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/firebase_options.dart';
import 'package:zipbuzz/routes.dart';
import 'package:zipbuzz/utils/constants/globals.dart';
import 'package:zipbuzz/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  await NotificationServices().initNotifications();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterUxcam.optIntoSchematicRecordings(); // Confirm that you have user permission for screen recording
    FlutterUxConfig config = FlutterUxConfig(
        userAppKey: "cnh8esuvyrp6r0o",
        enableAutomaticScreenNameTagging: false);
    FlutterUxcam.startWithConfiguration(config);
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
