import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/cache/app_cache_warmer.dart';
import 'package:readiculous_frontend/core/config/app_env.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/core/routing/routing.dart';
import 'package:readiculous_frontend/core/session/session_bootstrap.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';
import 'package:readiculous_frontend/generated/l10n.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  AppEnv.flavor = flavor;
  AppLogger.i(
    'Bootstrapping app: flavor=${AppEnv.name} '
    'apiBaseUrl=${AppEnv.apiBaseUrl} mlBaseUrl=${AppEnv.mlBaseUrl}',
  );

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).init();
  await SessionBootstrap.restoreIfPossible(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    unawaited(AppCacheWarmer.warmLibraries().catchError((_) {}));
    final userId = container.read(sessionProvider).userId;
    if (userId != null) {
      unawaited(AppCacheWarmer.warmForLoggedInUser(userId).catchError((_) {}));
      unawaited(
        container
            .read(myBooksProvider.future)
            .catchError((_) => <Map<String, dynamic>>[]),
      );
    }
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = Routing(ref).router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "READICULOUS",
      routerConfig: _router,
      theme: ThemeData(
        textTheme: GoogleFonts.patrickHandTextTheme(),
      ),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
