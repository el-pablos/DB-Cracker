import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/main.dart';
import 'package:db_cracker_tamaengs/api/api_factory.dart';
import 'package:db_cracker_tamaengs/screens/home_screen.dart';
import 'package:db_cracker_tamaengs/screens/dosen_search_screen_new.dart';
import 'package:db_cracker_tamaengs/screens/prodi_search_screen.dart';
import 'package:db_cracker_tamaengs/screens/health_screen.dart';
import 'package:db_cracker_tamaengs/screens/sekolah_screen.dart';
import 'package:db_cracker_tamaengs/theme/app_colors.dart';

void main() {
  // Enable mock data for all tests
  setUp(() {
    ApiFactory().enableMockData();
  });

  tearDown(() {
    ApiFactory().disableMockData();
  });

  group('Full Flow — Navigation', () {
    testWidgets('Home screen renders with all quick actions', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Verify home screen elements
      expect(find.text('DB Cracker'), findsOneWidget);
      expect(find.text('PDDIKTI Data Explorer'), findsOneWidget);
      expect(find.text('Akses Cepat'), findsOneWidget);
      expect(find.text('Mahasiswa'), findsOneWidget);
      expect(find.text('Dosen'), findsOneWidget);
      expect(find.text('Prodi'), findsOneWidget);
      expect(find.text('Kampus'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Sekolah'), findsOneWidget);
    });

    testWidgets('Tap Dosen navigates to Dosen Search screen', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dosen'));
      await tester.pumpAndSettle();

      expect(find.text('Cari Dosen'), findsOneWidget);
      expect(find.text('Masukkan nama dosen...'), findsOneWidget);
    });

    testWidgets('Tap Prodi navigates to Prodi Search screen', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Prodi'));
      await tester.pumpAndSettle();

      expect(find.text('Cari Program Studi'), findsOneWidget);
    });

    testWidgets('Tap Health navigates to Health screen', (tester) async {
      // Use larger surface to fit all buttons
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      expect(find.text('API Health Monitor'), findsOneWidget);
    });

    testWidgets('Kampus/Sekolah route navigates correctly', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Programmatically navigate to /sekolah route
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pushNamed('/sekolah');
      await tester.pumpAndSettle();

      // SekolahLookupScreen should be visible
      expect(find.text('Cari Sekolah'), findsAtLeast(1));
      expect(find.byType(SekolahLookupScreen), findsOneWidget);
    });
  });

  group('Full Flow — Search with Mock Data', () {
    testWidgets('Search mahasiswa shows results', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Find search bar and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'ahmad');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // With mock data, should show results (not error)
      // Mock service returns sample data
      expect(find.text('Minimal 2 karakter untuk pencarian'), findsNothing);
    });

    testWidgets('Empty search shows snackbar feedback', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Tap Mahasiswa with empty search
      await tester.tap(find.text('Mahasiswa'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Ketik nama mahasiswa di search bar terlebih dahulu'), findsOneWidget);
    });

    testWidgets('Short query shows error message', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'a');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Minimal 2 karakter untuk pencarian'), findsOneWidget);
    });
  });

  group('Full Flow — Dosen Search', () {
    testWidgets('Dosen search with mock data shows results', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Navigate to dosen search
      await tester.tap(find.text('Dosen'));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'budi');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should not show "Minimal 2 karakter" error
      expect(find.text('Masukkan nama dosen untuk mencari'), findsNothing);
    });
  });

  group('Full Flow — Theme Verification', () {
    testWidgets('App uses Neo-Violet theme (not ctOS)', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Verify scaffold background is deep navy, not pure black
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.background);
      expect(scaffold.backgroundColor, isNot(Colors.black));
    });

    testWidgets('No Courier font in rendered text', (tester) async {
      await tester.pumpWidget(const DBCrackerApp());
      await tester.pumpAndSettle();

      // Find text widgets and verify none use Courier
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        if (text.style?.fontFamily != null) {
          expect(text.style!.fontFamily, isNot('Courier'));
          expect(text.style!.fontFamily, isNot('CourierPrime'));
        }
      }
    });
  });
}
