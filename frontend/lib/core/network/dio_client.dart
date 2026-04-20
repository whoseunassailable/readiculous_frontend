import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {
  DioClient._();

  static final Dio main = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )
    ..transformer = BackgroundTransformer()
    ..interceptors.add(_ApiLoggerInterceptor());
}

class _ApiLoggerInterceptor extends Interceptor {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 4,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static const String _startTimeKey = '__api_log_start_time__';

  bool _suppressResponseBody(RequestOptions options) {
    final normalizedPath = options.path.replaceAll(RegExp(r'/+$'), '');
    return options.method.toUpperCase() == 'GET' &&
        normalizedPath == '/libraries';
  }

  String _pretty(Object? value) {
    if (value == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  String _headers(Map<String, dynamic> headers) {
    return _pretty(headers.map((key, value) => MapEntry(key, '$value')));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer()
      ..writeln('HTTP REQUEST')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('Headers:')
      ..writeln(_headers(options.headers));

    if (options.queryParameters.isNotEmpty) {
      buffer
        ..writeln('Query:')
        ..writeln(_pretty(options.queryParameters));
    }

    if (options.method.toUpperCase() != 'GET' && options.data != null) {
      buffer
        ..writeln('Body:')
        ..writeln(_pretty(options.data));
    }

    _logger.i(buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startedAt = response.requestOptions.extra[_startTimeKey] as int? ?? 0;
    final elapsedMs = startedAt == 0
        ? null
        : DateTime.now().millisecondsSinceEpoch - startedAt;

    final buffer = StringBuffer()
      ..writeln('HTTP RESPONSE')
      ..writeln(
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      )
      ..writeln(
        'Status: ${response.statusCode} ${response.statusMessage ?? ''}'
        '${elapsedMs != null ? ' | ${elapsedMs}ms' : ''}',
      )
      ..writeln('Headers:')
      ..writeln(_headers(response.headers.map));

    if (_suppressResponseBody(response.requestOptions)) {
      buffer.writeln('Body: <suppressed for GET /libraries>');
    } else {
      buffer
        ..writeln('Body:')
        ..writeln(_pretty(response.data));
    }

    _logger.i(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startedAt = err.requestOptions.extra[_startTimeKey] as int? ?? 0;
    final elapsedMs = startedAt == 0
        ? null
        : DateTime.now().millisecondsSinceEpoch - startedAt;

    final buffer = StringBuffer()
      ..writeln('HTTP ERROR')
      ..writeln('${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln(
        'Status: ${err.response?.statusCode ?? 'n/a'} '
        '${err.response?.statusMessage ?? ''}'
        '${elapsedMs != null ? ' | ${elapsedMs}ms' : ''}',
      )
      ..writeln('Message: ${err.message}');

    if (err.response != null) {
      buffer
        ..writeln('Headers:')
        ..writeln(_headers(err.response!.headers.map));

      if (_suppressResponseBody(err.requestOptions)) {
        buffer.writeln('Body: <suppressed for GET /libraries>');
      } else {
        buffer
          ..writeln('Body:')
          ..writeln(_pretty(err.response?.data));
      }
    }

    _logger.e(buffer.toString());
    handler.next(err);
  }
}
