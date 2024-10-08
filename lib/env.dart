import 'dart:io';

enum Environment { dev, prod, stage, testing }

abstract class AppEnvironment {
  static late Environment _env;
  static Environment get environment => _env;
  static late String _appVersion;
  static String get appVersion => _appVersion;
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.abacus.zipbuzz';
  static const appStoreUrl = 'https://apps.apple.com/in/app/buzz-me/id6477519288';

  static String get getStoreUrl => Platform.isAndroid ? playStoreUrl : appStoreUrl;

  static const websiteUrl = 'https://buzzme.site';

  static late String cloudFunctionBaseUrl,
      realtimeDataBaseUrl,
      dynamicLinkBaseUrl,
      appDisplayName,
      appEnvironment,
      uxCamKey;

  static setupEnv(Environment env) {
    _env = env;

    /// Update this before every release
    _appVersion = "1.0.68";

    switch (env) {
      case Environment.dev:
        cloudFunctionBaseUrl = "https://dev.buzzme.site/";
        realtimeDataBaseUrl = 'https://shwipt-dev-default-rtdb.firebaseio.com/';
        dynamicLinkBaseUrl = 'https://zipbuzz.page.link';
        appDisplayName = 'Buzz.Me';
        appEnvironment = 'dev';
        uxCamKey = 'cnh8esuvyrp6r0o';
        break;
      case Environment.testing:
        cloudFunctionBaseUrl = "";
        realtimeDataBaseUrl = '';
        dynamicLinkBaseUrl = '';
        appDisplayName = '';
        appEnvironment = '';
        uxCamKey = '';
        break;
      case Environment.stage:
        cloudFunctionBaseUrl = "";
        realtimeDataBaseUrl = '';
        dynamicLinkBaseUrl = '';
        appDisplayName = '';
        appEnvironment = '';
        uxCamKey = '';
        break;
      case Environment.prod:
        cloudFunctionBaseUrl = "https://web.buzzme.site/";
        realtimeDataBaseUrl = '';
        dynamicLinkBaseUrl = '';
        appDisplayName = 'Buzz.Me';
        appEnvironment = 'prod';
        uxCamKey = 'cnh8esuvyrp6r0o';
        break;
    }
  }
}

class ConnUtils {
  final cloudFunctionBaseUrl = AppEnvironment.cloudFunctionBaseUrl;
  final realtimeDataBaseUrl = AppEnvironment.realtimeDataBaseUrl;
  final dynamicLinkBaseUrl = AppEnvironment.dynamicLinkBaseUrl;
  final appDisplayName = AppEnvironment.appDisplayName;
}
