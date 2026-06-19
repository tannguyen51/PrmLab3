import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'screens/search/search_screen.dart';
import 'services/openalex_service.dart';
import 'services/publication_repository.dart';
import 'state/search_provider.dart';

class JournalTrendAnalyzerApp extends StatelessWidget {
  const JournalTrendAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => const OpenAlexService()),
        ProxyProvider<OpenAlexService, PublicationRepository>(
          update: (_, service, previousRepository) =>
              PublicationRepository(service),
        ),
        ChangeNotifierProxyProvider<PublicationRepository, SearchProvider>(
          create: (_) => SearchProvider(),
          update: (_, repository, provider) {
            final searchProvider = provider ?? SearchProvider();
            searchProvider.repository = repository;
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
        home: const SearchScreen(),
      ),
    );
  }
}
