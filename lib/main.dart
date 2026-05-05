import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/prodi_detail_screen.dart';
import 'screens/prodi_search_screen.dart';
import 'screens/pt_detail_screen.dart';
import 'screens/dosen_search_screen_new.dart';
import 'screens/dosen_detail_screen.dart';
import 'screens/health_screen.dart';
import 'screens/sekolah_screen.dart';
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

  runApp(const DBCrackerApp());
}

class DBCrackerApp extends StatelessWidget {
  const DBCrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApiFactory>(
      create: (_) {
        final factory = ApiFactory();
        // Enable mock data for testing when APIs are down
        // TODO: Remove this when PDDIKTI APIs recover
        if (kIsWeb) factory.enableMockData();
        return factory;
      },
      child: MaterialApp(
        title: 'DB Cracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        routes: {
          '/prodi/search': (context) => const ProdiSearchScreen(),
          '/dosen/search': (context) => const DosenSearchScreenNew(),
          '/health': (context) => const HealthScreen(),
          '/sekolah': (context) => const SekolahLookupScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/prodi/detail/') ?? false) {
            final prodiId = settings.name!.split('/').last;
            if (prodiId.isEmpty) {
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
            final args = settings.arguments is Map<String, dynamic>
                ? settings.arguments as Map<String, dynamic>
                : null;
            return MaterialPageRoute(
              builder: (context) => ProdiDetailScreen(
                prodiId: prodiId,
                prodiName: args?['prodiName'] ?? 'Program Studi',
              ),
            );
          } else if (settings.name?.startsWith('/pt/detail/') ?? false) {
            final ptId = settings.name!.split('/').last;
            if (ptId.isEmpty) {
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
            final args = settings.arguments is Map<String, dynamic>
                ? settings.arguments as Map<String, dynamic>
                : null;
            return MaterialPageRoute(
              builder: (context) => PtDetailScreen(
                ptId: ptId,
                ptName: args?['ptName'] ?? 'Institusi',
              ),
            );
          } else if (settings.name?.startsWith('/dosen/detail/') ?? false) {
            final dosenId = settings.name!.split('/').last;
            if (dosenId.isEmpty) {
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
            final args = settings.arguments is Map<String, dynamic>
                ? settings.arguments as Map<String, dynamic>
                : null;
            return MaterialPageRoute(
              builder: (context) => DosenDetailScreen(
                dosenId: dosenId,
                dosenName: args?['dosenName'] ?? 'Dosen',
              ),
            );
          }
          // Fallback route
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        },
      ),
    );
  }
}
