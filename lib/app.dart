import 'package:control_parental_child/core/theme/app_theme.dart';
import 'package:control_parental_child/core/theme/theme_provider.dart';
import 'package:control_parental_child/features/home/domain/provider/game_time_provider.dart';
import 'package:control_parental_child/features/home/ui/pages/home_page.dart';

import 'package:control_parental_child/features/link_device/ui/pages/link_error_page.dart';
import 'package:control_parental_child/features/link_device/ui/pages/link_success_page.dart';
import 'package:control_parental_child/features/link_device/ui/pages/scan_link_code_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameTimeProvider()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final lightTheme = AppTheme.lightTheme();
    final darkTheme = AppTheme.darkTheme();

    return MaterialApp(
      title: 'Control Parental',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/scan-link-code',
      routes: {
        '/child-home': (_) =>
            const Scaffold(body: Center(child: Text('Child Home'))),
        '/scan-link-code': (_) => const ScanLinkCodePage(),
        '/link-success': (_) => const LinkSuccessPage(),
        '/link-error': (_) => const LinkErrorPage(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
