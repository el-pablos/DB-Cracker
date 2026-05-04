import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/widgets/ctos_container.dart';

void main() {
  group('CtOSContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSContainer(
              child: Text('Container Content'),
            ),
          ),
        ),
      );
      expect(find.text('Container Content'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSContainer(
              padding: EdgeInsets.all(32),
              child: Text('Padded'),
            ),
          ),
        ),
      );
      expect(find.text('Padded'), findsOneWidget);
    });
  });

  group('CtOSText', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSText('Hello World'),
          ),
        ),
      );
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies custom fontSize', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSText('Big Text', fontSize: 24),
          ),
        ),
      );
      expect(find.text('Big Text'), findsOneWidget);
    });
  });

  group('CtOSHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSHeader(title: 'HEADER TITLE'),
          ),
        ),
      );
      expect(find.text('HEADER TITLE'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSHeader(
              title: 'TITLE',
              subtitle: 'Subtitle text',
            ),
          ),
        ),
      );
      expect(find.text('TITLE'), findsOneWidget);
      expect(find.text('Subtitle text'), findsOneWidget);
    });
  });

  group('CtOSButton', () {
    testWidgets('renders button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSButton(
              text: 'CLICK ME',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('CLICK ME'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSButton(
              text: 'TAP',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('TAP'));
      expect(pressed, true);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSButton(
              text: 'WITH ICON',
              icon: Icons.refresh,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
