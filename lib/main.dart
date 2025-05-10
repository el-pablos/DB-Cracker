import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'api/api_factory.dart';
import 'utils/constants.dart';
import 'utils/screen_utils.dart';

void main() {
  // Enable Flutter Web error logging in console
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error: ${details.exception}');
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi ScreenUtils secara default dengan context minimal
    // Ini akan diupdate dengan context yang lebih baik nanti dalam widget tree
    ScreenUtils.init(context);
    
    return Provider<ApiFactory>(
      create: (_) => ApiFactory(),
      child: MaterialApp(
        title: 'DB Cracker - Tamaengs',
        debugShowCheckedModeBanner: false,
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
        home: Builder(
          builder: (context) {
            // Re-inisialisasi ScreenUtils dengan context yang lebih baik
            ScreenUtils.init(context);
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}