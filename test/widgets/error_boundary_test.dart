import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/widgets/error_boundary.dart';

void main() {
  group('CtOSErrorBoundary', () {
    testWidgets('renders child when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSErrorBoundary(
              child: Text('Normal Content'),
            ),
          ),
        ),
      );
      expect(find.text('Normal Content'), findsOneWidget);
    });

    testWidgets('shows error widget when errorMessage is set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSErrorBoundary(
              errorMessage: 'Something went wrong',
              child: Text('Normal Content'),
            ),
          ),
        ),
      );
      expect(find.text('Normal Content'), findsNothing);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSErrorBoundary(
              errorMessage: 'Error occurred',
              onRetry: () => retried = true,
              child: const Text('Content'),
            ),
          ),
        ),
      );
      expect(find.text('Coba Lagi'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      expect(retried, true);
    });

    testWidgets('hides retry button when showRetryButton is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSErrorBoundary(
              errorMessage: 'Error',
              showRetryButton: false,
              onRetry: () {},
              child: const Text('Content'),
            ),
          ),
        ),
      );
      expect(find.text('COBA LAGI'), findsNothing);
    });
  });

  group('CtOSEmptyWidget', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CtOSEmptyWidget(
              title: 'KOSONG',
              message: 'Tidak ada data',
            ),
          ),
        ),
      );
      expect(find.text('KOSONG'), findsOneWidget);
      expect(find.text('Tidak ada data'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      bool actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtOSEmptyWidget(
              title: 'KOSONG',
              message: 'Tidak ada data',
              actionText: 'REFRESH',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );
      expect(find.text('REFRESH'), findsOneWidget);
      await tester.tap(find.text('REFRESH'));
      expect(actionCalled, true);
    });
  });
}
