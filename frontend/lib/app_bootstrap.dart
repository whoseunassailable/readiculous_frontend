import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/config/app_env.dart';
import 'package:readiculous_frontend/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';

import 'my_app.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  AppEnv.flavor = flavor;
  AppLogger.i(
    'Bootstrapping app: flavor=${AppEnv.name} '
    'devConnectionMode=${AppEnv.isDev ? AppEnv.devConnectionMode.name : 'n/a'} '
    'apiBaseUrl=${AppEnv.apiBaseUrl} mlBaseUrl=${AppEnv.mlBaseUrl}',
  );

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
      FlutterNativeSplash.remove();
      if (container.read(sessionProvider).userId != null) {
        container.read(myBooksProvider.future).ignore();
      }
    },
  );
}
