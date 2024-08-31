import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/firebase_options/firebase_options_dev.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/services/dio_services.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptionsDev.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AppEnvironment.setupEnv(Environment.dev);
  await GetStorage.init();
  await DioServices.getToken();
  runApp(const ProviderScope(child: MyApp()));
}