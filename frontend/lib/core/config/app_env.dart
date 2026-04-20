enum AppFlavor { dev, prod }

class AppEnv {
  AppEnv._();

  static AppFlavor flavor = AppFlavor.dev;
  static const String _devApiHost = String.fromEnvironment(
    'DEV_API_HOST',
    defaultValue: '127.0.0.1',
  );
  static const String _devMlHost = String.fromEnvironment(
    'DEV_ML_HOST',
    defaultValue: '127.0.0.1',
  );
  static const String _prodApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000/api',
  );
  static const String _prodMlBaseUrl = String.fromEnvironment(
    'ML_BASE_URL',
    defaultValue: 'http://127.0.0.1:6000',
  );

  static bool get isDev => flavor == AppFlavor.dev;
  static bool get isProd => flavor == AppFlavor.prod;

  static String get name => switch (flavor) {
        AppFlavor.dev => 'dev',
        AppFlavor.prod => 'prod',
      };

  static String get apiBaseUrl => switch (flavor) {
        AppFlavor.dev => 'http://$_devApiHost:5000/api',
        AppFlavor.prod => _prodApiBaseUrl,
      };

  static String get mlBaseUrl => switch (flavor) {
        AppFlavor.dev => 'http://$_devMlHost:6000',
        AppFlavor.prod => _prodMlBaseUrl,
      };
}
