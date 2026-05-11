import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cozy_feels_app/features/history/presentation/screens/home_screen.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CozyFeelsApp());
}

class CozyFeelsApp extends StatefulWidget {
  const CozyFeelsApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _CozyFeelsAppState? state =
        context.findAncestorStateOfType<_CozyFeelsAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<CozyFeelsApp> createState() => _CozyFeelsAppState();
}

class _CozyFeelsAppState extends State<CozyFeelsApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    final storage = MoodStorageService();
    String? langCode = await storage.loadLanguage();
    if (langCode != null) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });

    MoodStorageService().saveLanguage(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,

      theme: ThemeData(
        fontFamily: 'Dongle',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
