import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_navigation_shell.dart';
import 'services/analytics_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/openalex_service.dart';
import 'services/profile_firebase_service.dart';
import 'services/publication_repository.dart';
import 'state/search_provider.dart';
import 'viewmodels/analytics_view_model.dart';

class JournalTrendAnalyzerApp extends StatelessWidget {
  const JournalTrendAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => const OpenAlexService()),
        Provider(create: (_) => FirebaseAuthService()),
        Provider(create: (_) => AnalyticsService()),
        Provider(create: (_) => ProfileFirebaseService()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
        ProxyProvider<OpenAlexService, PublicationRepository>(
          update: (_, service, previousRepository) =>
              PublicationRepository(service),
        ),
        ChangeNotifierProxyProvider2<
          PublicationRepository,
          AnalyticsService,
          SearchProvider
        >(
          create: (_) => SearchProvider(),
          update: (_, repository, analytics, provider) {
            final searchProvider = provider ?? SearchProvider();
            searchProvider.repository = repository;
            searchProvider.analyticsService = analytics;
            return searchProvider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Journal Trend Analyzer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF22D3EE),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<FirebaseAuthService>();

    return StreamBuilder(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationShell();
        }

        return const LoginScreen();
      },
    );
  }
}
