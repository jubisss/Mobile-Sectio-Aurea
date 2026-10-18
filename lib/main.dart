import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sectio_aurea/rotas.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          title: 'Sectio Aurea',
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],
          themeMode: currentMode,
          theme: ThemeData(
            fontFamily: 'Poppins',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xfff4f1eb),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xfff4f1eb),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xff121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff121212),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white70),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xff1e1e1e),
              selectedItemColor: Colors.tealAccent,
              unselectedItemColor: Colors.white30,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xff1e1e1e),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
