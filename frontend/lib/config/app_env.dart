import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

enum AppFlavor { dev, prod }

enum DevConnectionMode { lan, reverse, emulator }

class AppEnv {
  AppEnv._();

  static AppFlavor flavor = AppFlavor.dev;
  static const String _devApiHost = String.fromEnvironment(
    'DEV_API_HOST',
    defaultValue: '192.168.4.75',
  );
  static const String _devMlHost = String.fromEnvironment(
    'DEV_ML_HOST',
    defaultValue: '192.168.4.75',
  );
  // 'auto' picks the right default per-platform at runtime (emulator on
  // Android, reverse/127.0.0.1 elsewhere) so a plain `flutter run` works with
  // no dart-define at all. Pass DEV_CONNECTION_MODE explicitly to override
  // (e.g. 'lan' + DEV_API_HOST for a physical device on the same wifi).
  static const String _devConnectionMode = String.fromEnvironment(
    'DEV_CONNECTION_MODE',
    defaultValue: 'auto',
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

  static DevConnectionMode get devConnectionMode {
    final mode = _devConnectionMode.toLowerCase();
    return switch (mode) {
      'reverse' => DevConnectionMode.reverse,
      'emulator' => DevConnectionMode.emulator,
      'lan' => DevConnectionMode.lan,
      // 'auto' (the default) or anything unrecognized: infer from platform.
      _ => (!kIsWeb && Platform.isAndroid)
          ? DevConnectionMode.emulator
          : DevConnectionMode.reverse,
    };
  }

  static String get name => switch (flavor) {
        AppFlavor.dev => 'dev',
        AppFlavor.prod => 'prod',
      };

  static String get _resolvedDevHost => switch (devConnectionMode) {
        DevConnectionMode.lan => _devApiHost,
        DevConnectionMode.reverse => '127.0.0.1',
        DevConnectionMode.emulator => '10.0.2.2',
      };

  static String get _resolvedDevMlHost => switch (devConnectionMode) {
        DevConnectionMode.lan => _devMlHost,
        DevConnectionMode.reverse => '127.0.0.1',
        DevConnectionMode.emulator => '10.0.2.2',
      };

  static String get apiBaseUrl => switch (flavor) {
        AppFlavor.dev => 'http://$_resolvedDevHost:5000/api',
        AppFlavor.prod => _prodApiBaseUrl,
      };

  static String get mlBaseUrl => switch (flavor) {
        AppFlavor.dev => 'http://$_resolvedDevMlHost:6000',
        AppFlavor.prod => _prodMlBaseUrl,
      };
}
