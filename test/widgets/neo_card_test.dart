import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/widgets/core/neo_card.dart';
import 'package:db_cracker_tamaengs/theme/app_theme.dart';
import 'package:db_cracker_tamaengs/theme/app_spacing.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('NeoCard — rendering', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(buildApp(
        child: const NeoCard(
          child: Text('Hello Neo'),
        ),
      ));

      expect(find.text('Hello Neo'), findsOneWidget);
    });

    testWidgets('renders complex child widget tree', (tester) async {
      await tester.pumpWidget(buildApp(
        child: NeoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star),
              Text('Star Card'),
            ],
          ),
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Star Card'), findsOneWidget);
    });
  });

  group('NeoCard — tap behavior', () {
    testWidgets('responds to tap when onTap is provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildApp(
        child: NeoCard(
          onTap: () => tapped = true,
          child: const Text('Tap me'),
        ),
      ));

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('wraps in InkWell when onTap is provided', (tester) async {
      await tester.pumpWidget(buildApp(
        child: NeoCard(
          onTap: () {},
          child: const Text('Tappable'),
        ),
      ));

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('does NOT wrap in InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(buildApp(
        child: const NeoCard(
          child: Text('Static'),
        ),
      ));

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('does NOT respond to tap when onTap is null', (tester) async {
      // Verify no Material/InkWell ancestor that could absorb taps
      await tester.pumpWidget(buildApp(
        child: const NeoCard(
          child: Text('No tap'),
        ),
      ));

      // No InkWell means no tap handler — widget is purely visual
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNothing);
    });
  });

  group('NeoCard — border radius', () {
    testWidgets('applies default border radius (radiusLg = 12)',
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: const NeoCard(
          child: Text('Default radius'),
        ),
      ));

      // Find the Container that holds the BoxDecoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(AppSpacing.radiusLg)),
      );
    });

    testWidgets('applies custom border radius when specified', (tester) async {
      const customRadius = 24.0;

      await tester.pumpWidget(buildApp(
        child: const NeoCard(
          borderRadius: customRadius,
          child: Text('Custom radius'),
        ),
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(customRadius)),
      );
    });

    testWidgets('InkWell borderRadius matches card radius when tappable',
        (tester) async {
      const customRadius = 20.0;

      await tester.pumpWidget(buildApp(
        child: NeoCard(
          borderRadius: customRadius,
          onTap: () {},
          child: const Text('Tappable radius'),
        ),
      ));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(
        inkWell.borderRadius,
        equals(BorderRadius.circular(customRadius)),
      );
    });
  });
}
