import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/features/genre_trends/domain/entities/genre_trend.dart';
import 'package:readiculous_frontend/features/genre_trends/presentation/pages/genre_trends_page.dart';
import 'package:readiculous_frontend/features/genre_trends/presentation/state_management/trends_providers.dart';

Future<void> _pump(WidgetTester tester, List<GenreTrend> trends) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [genreTrendsProvider.overrideWith((ref) async => trends)],
    child: const MaterialApp(home: GenreTrendsPage()),
  ));
  // Bars animate in one after another.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lists genres with their scores, highest first', (tester) async {
    await _pump(tester, const [
      GenreTrend(genreId: 23, name: 'Fantasy', score: 9.4),
      GenreTrend(genreId: 36, name: 'Mystery', score: 8.9),
    ]);

    expect(find.text('Fantasy'), findsOneWidget);
    expect(find.text('9.4'), findsOneWidget);
    expect(find.text('Mystery'), findsOneWidget);
    expect(find.text('8.9'), findsOneWidget);
    expect(find.text('2 genres tracked'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no trends', (tester) async {
    await _pump(tester, const []);
    expect(find.text('No trend data yet.'), findsOneWidget);
  });
}
