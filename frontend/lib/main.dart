import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'generated/l10n.dart';
import 'core/routing/routing.dart';
import 'core/session/session_provider.dart';
import 'core/features/library_association/presentation/state_management/libraries_provider.dart';
import 'core/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // Wait for the first frame to render (login/home screen is fully visible and
  // interactive) before starting any background fetches. This keeps the UI
  // responsive — pre-warming no longer competes with the initial render.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    unawaited(container.read(allLibrariesProvider.future).catchError((_) {}));
    final userId = container.read(sessionProvider).userId;
    if (userId != null) {
      unawaited(container.read(myBooksProvider.future).catchError((_) {}));
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