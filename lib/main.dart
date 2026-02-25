import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'generated/l10n.dart';
import 'core/routing/routing.dart';
import 'core/session/session_provider.dart';

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

  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "READICULOUS",
      routerConfig: Routing(ref).router, // ✅ pass ref into routing
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
