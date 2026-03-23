// lib/core/utils/app_logger.dart

import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._(); // prevent instantiation

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // call-stack lines shown on debug/info
      errorMethodCount: 8, // more context on errors
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );

  static void v(String message) => _logger.t(message);

  static void d(String message) => _logger.d(message);

  static void i(String message) => _logger.i(message);

  static void w(String message) => _logger.w(message);

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
