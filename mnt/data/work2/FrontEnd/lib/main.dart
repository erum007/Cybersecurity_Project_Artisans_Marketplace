import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_screens.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ArtisansMarketplaceApp());
}

class ArtisansMarketplaceApp extends StatelessWidget {
  const ArtisansMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: MaterialApp(
        title: 'Artisans Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const RootScreen(),
      ),
    );
  }
}
