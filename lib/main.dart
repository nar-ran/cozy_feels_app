import 'package:cozy_feels_app/core/security/security_service.dart';
import 'package:cozy_feels_app/core/security/widgets/lock_screen.dart';
import 'package:cozy_feels_app/core/theme/theme_controller.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cozy_feels_app/features/history/presentation/screens/home_screen.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'package:cozy_feels_app/features/history/domain/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  final storage = MoodStorageService();
  String timezone;
  final String? savedTimezone = await storage.loadTimezone();

  if (savedTimezone != null) {
    timezone = savedTimezone;
  } else {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      timezone = timezoneInfo.identifier;
      await storage.saveTimezone(timezone);
    } catch (e) {
      timezone = 'America/New_York';
    }
  }

  try {
    tz.setLocalLocation(tz.getLocation(timezone));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  final notificationService = NotificationService();
  await notificationService.initNotification();

  // Inicializar tema guardado
  await ThemeController.instance.init();

  // Inicializar servicio de seguridad (PIN y Biometría)
  await SecurityService.instance.init();

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

class _CozyFeelsAppState extends State<CozyFeelsApp>
    with WidgetsBindingObserver {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocale();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      SecurityService.instance.lock();
    }
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
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          theme: ThemeController.instance.themeData,
          home: const HomeScreen(),
          builder: (context, child) {
            return ListenableBuilder(
              listenable: SecurityService.instance,
              builder: (context, _) {
                return Stack(
                  children: [
                    if (child != null) child,
                    if (SecurityService.instance.isLocked)
                      const Positioned.fill(
                        child: LockScreen(),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
