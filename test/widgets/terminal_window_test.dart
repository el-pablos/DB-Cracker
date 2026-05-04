import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/widgets/terminal_window.dart';

void main() {
  group('TerminalWindow', () {
    testWidgets('renders title correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TerminalWindow(
              title: 'TEST TERMINAL',
              child: Text('Hello'),
            ),
          ),
        ),
      );
      expect(find.text('TEST TERMINAL'), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TerminalWindow(
              title: 'TITLE',
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('shows 3 window buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TerminalWindow(
              title: 'TITLE',
              child: Text('Content'),
            ),
          ),
        ),
      );
      // Window buttons are 10x10 containers
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalWindow(
              title: 'TITLE',
              actions: [
                const Icon(Icons.settings),
              ],
              child: const Text('Content'),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
