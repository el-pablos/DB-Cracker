import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/widgets/search/neo_search_bar.dart';
import 'package:db_cracker_tamaengs/theme/app_theme.dart';

void main() {
  Widget buildApp({
    TextEditingController? controller,
    String hintText = 'Search here...',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onClear,
    bool autofocus = false,
    bool isLoading = false,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NeoSearchBar(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onClear: onClear,
            autofocus: autofocus,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  group('NeoSearchBar — hint text', () {
    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(buildApp(hintText: 'Cari dosen...'));

      expect(find.text('Cari dosen...'), findsOneWidget);
    });

    testWidgets('renders default hint text when not specified',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: NeoSearchBar(),
          ),
        ),
      ));

      expect(
        find.text('Cari mahasiswa, dosen, atau prodi...'),
        findsOneWidget,
      );
    });
  });

  group('NeoSearchBar — clear button', () {
    testWidgets('clear button does NOT appear when text is empty',
        (tester) async {
      await tester.pumpWidget(buildApp());

      // No close icon when empty
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('clear button appears when text is entered', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildApp(controller: controller));

      // Enter text
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      // Clear button should now be visible
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('tapping clear button clears the text', (tester) async {
      final controller = TextEditingController();
      var clearCalled = false;

      await tester.pumpWidget(buildApp(
        controller: controller,
        onClear: () => clearCalled = true,
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Tap clear
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(clearCalled, isTrue);
    });
  });

  group('NeoSearchBar — onSubmitted callback', () {
    testWidgets('onSubmitted fires on submit action', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(buildApp(
        onSubmitted: (value) => submittedValue = value,
      ));

      await tester.enterText(find.byType(TextField), 'search term');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedValue, equals('search term'));
    });

    testWidgets('onSubmitted fires with empty string when submitted without typing',
        (tester) async {
      String? submittedValue;

      await tester.pumpWidget(buildApp(
        onSubmitted: (value) => submittedValue = value,
        autofocus: true,
      ));
      await tester.pump();

      // Submit with empty text — callback fires with ''
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedValue, equals(''));
    });
  });

  group('NeoSearchBar — loading indicator', () {
    testWidgets('loading indicator shows when isLoading=true', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading indicator hidden when isLoading=false',
        (tester) async {
      await tester.pumpWidget(buildApp(isLoading: false));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('clear button hidden when isLoading=true even with text',
        (tester) async {
      final controller = TextEditingController(text: 'some text');

      await tester.pumpWidget(buildApp(
        controller: controller,
        isLoading: true,
      ));
      await tester.pump();

      // Loading indicator takes priority over clear button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('NeoSearchBar — search icon', () {
    testWidgets('search icon is always visible', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });
}
