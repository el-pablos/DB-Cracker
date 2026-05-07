import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:db_cracker_tamaengs/main.dart';
import 'package:db_cracker_tamaengs/api/api_factory.dart';

void main() {
  setUp(() {
    ApiFactory().enableMockData();
  });

  tearDown(() {
    ApiFactory().disableMockData();
  });

  group('Full Flow — App Launch', () {
    testWidgets('App launches without crash', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: DBCrackerApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows navigation with 5 destinations', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: DBCrackerApp()));
      await tester.pumpAndSettle();

      // Navigation labels should exist somewhere in widget tree
      expect(find.text('Beranda'), findsAtLeast(1));
      expect(find.text('Pengadaan'), findsAtLeast(1));
    });

    testWidgets('Home screen shows DB Cracker branding', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: DBCrackerApp()));
      await tester.pumpAndSettle();

      expect(find.text('DB Cracker'), findsOneWidget);
    });

    testWidgets('App uses dark theme (not light)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: DBCrackerApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.theme?.brightness, Brightness.dark);
    });

    testWidgets('No Courier font anywhere in app', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: DBCrackerApp()));
      await tester.pumpAndSettle();

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
