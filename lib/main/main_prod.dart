import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/firebase_options/firebase_options_prod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptionsProd.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AppEnvironment.setupEnv(Environment.prod);
  await GetStorage.init();
  // await DioServices.getToken();
  runApp(const ProviderScope(child: MyApp()));
}
