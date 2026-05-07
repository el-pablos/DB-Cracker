import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'api/api_factory.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Enable Flutter error logging in debug
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('Flutter error: ${details.exception}');
  };

  runApp(const ProviderScope(child: DBCrackerApp()));
}

class DBCrackerApp extends StatelessWidget {
  const DBCrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return legacy_provider.Provider<ApiFactory>(
      create: (_) => ApiFactory(),
      child: MaterialApp.router(
        title: 'DB Cracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
