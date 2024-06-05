enum Environment { dev, prod, stage, testing }

abstract class AppEnvironment {
  static late Environment _env;
  static Environment get environment => _env;

  static late String cloudFunctionBaseUrl,
      realtimeDataBaseUrl,
      dynamicLinkBaseUrl,
      appDisplayName,
      appEnvironment,
      uxCamKey;

  static setupEnv(Environment env) {
    _env = env;
    switch (env) {
      case Environment.dev:
        cloudFunctionBaseUrl = "https://dev.zipbuzz.me/";
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
        cloudFunctionBaseUrl = "https://admin.zipbuzz.me/";
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
