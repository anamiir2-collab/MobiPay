import 'package:flutter/material.dart';

import 'core/app.dart';
import 'core/style.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MobiPayApp());
}

class MobiPayApp extends StatelessWidget {
  const MobiPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([App.locale, App.dark]),
      builder: (context, _) {
        return Directionality(
          textDirection: App.dir,
          child: MaterialApp(
            title: 'MobiPay',
            debugShowCheckedModeBanner: false,
            locale: App.locale.value,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: C.bg,
              colorScheme: ColorScheme.fromSeed(seedColor: C.primary, brightness: Brightness.light),
              fontFamily: 'Inter',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: C.dBg,
              colorScheme: ColorScheme.fromSeed(seedColor: C.primary, brightness: Brightness.dark),
              fontFamily: 'Inter',
            ),
            themeMode: App.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
