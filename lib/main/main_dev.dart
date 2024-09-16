import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/env.dart';
import 'package:zipbuzz/firebase_options/firebase_options_dev.dart';
import 'package:zipbuzz/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptionsDev.currentPlatform,
      name: 'zipbuzz-dev',
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptionsDev.currentPlatform,
    );
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AppEnvironment.setupEnv(Environment.dev);
  await GetStorage.init();
  runApp(const ProviderScope(child: MyApp()));
}
