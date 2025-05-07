import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'api/pddikti_api.dart';
import 'utils/constants.dart';  // Fix: Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<PddiktiApi>(
      create: (_) => PddiktiApi(),
      child: MaterialApp(
        title: 'DB Cracker - Tamaengs',
        theme: ThemeData(
          primaryColor: HackerColors.primary,
          scaffoldBackgroundColor: HackerColors.background,
          colorScheme: ColorScheme.dark(
            primary: HackerColors.primary,
            secondary: HackerColors.accent,
            surface: HackerColors.surface,
            background: HackerColors.background,
            error: HackerColors.error,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: HackerColors.text),
            bodyMedium: TextStyle(color: HackerColors.text),
            displayLarge: TextStyle(color: HackerColors.primary),
            displayMedium: TextStyle(color: HackerColors.primary),
            displaySmall: TextStyle(color: HackerColors.primary),
          ),
          fontFamily: 'Courier',
          cardTheme: CardTheme(
            color: HackerColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: HackerColors.accent, width: 1),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: HackerColors.surface,
            foregroundColor: HackerColors.primary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: HackerColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: HackerColors.accent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: HackerColors.accent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: HackerColors.primary, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: HackerColors.text,
              backgroundColor: HackerColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}