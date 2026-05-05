import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/backup_service.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/history_bottom_sheet.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/mood_editor_dialog.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/mood_selector_grid.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/onboarding_overlay.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/settings_bottom_sheet.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/timezone_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showOnboarding = false;
  final MoodStorageService _storage = MoodStorageService();

  final TextEditingController _textController = TextEditingController();
  final List<HistoryEntry> _myHistory = [];
  final emojis = AppAssets.sentimentEmojis.entries.toList();
  String _selectedTimezone = 'America/New_York';
  final Map<String, String> _timezoneMap = {
    'Eastern Time (US/Canada)': 'America/New_York',
    'Central Europe (Madrid/Paris)': 'Europe/Madrid',
    'Argentina / Brazil (South)': 'America/Argentina/Buenos_Aires',
    'Singapore / SE Asia': 'Asia/Singapore',
    'London / Dublin (GMT)': 'Europe/London',
  };

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initData();
  }

  Future<void> _initData() async {
    final history = await _storage.loadHistory();
    final timezone = await _storage.loadTimezone();
    final seenOnboarding = await _storage.hasSeenOnboarding();

    setState(() {
      _myHistory.addAll(history);
      if (timezone != null) _selectedTimezone = timezone;
      _showOnboarding = !seenOnboarding;
    });
  }

  Future<void> _saveHistory() async {
    await _storage.saveHistory(_myHistory);
  }

  Future<void> _saveTimezone(String timezone) async {
    await _storage.saveTimezone(timezone);
  }

  Future<void> _closeOnboarding() async {
    await _storage.setOnboardingSeen();
    setState(() => _showOnboarding = false);
  }

  void _updateHistoryEntry(int index, String newMessage, String newEmoji) {
    setState(() {
      _myHistory[index] = HistoryEntry(
        date: _myHistory[index].date,
        message: newMessage,
        emojiPath: newEmoji,
      );
    });
    _saveHistory();
  }

  void _saveMood(String selectedEmojiPath) {
    final location = tz.getLocation(_selectedTimezone);
    final now = tz.TZDateTime.now(location);

    bool alreadyExists = _myHistory.any((entry) {
      final entryDate = tz.TZDateTime.from(entry.date, location);
      return entryDate.year == now.year &&
          entryDate.month == now.month &&
          entryDate.day == now.day;
    });

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("You've already recorded your mood for today!"),
          backgroundColor: AppColors.rosaFuerte,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _myHistory.insert(
          0,
          HistoryEntry(
            date: now,
            message: _textController.text,
            emojiPath: selectedEmojiPath,
          ));
      _textController.clear();
    });
    _saveHistory();
    FocusScope.of(context).unfocus();
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (context) => TimezoneSelectorDialog(
        timezoneMap: _timezoneMap,
        selectedTimezone: _selectedTimezone,
        onSelect: (tz) {
          setState(() => _selectedTimezone = tz);
          _saveTimezone(tz);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditDialog(int index, HistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => MoodEditorDialog(
        date: entry.date,
        initialMessage: entry.message,
        initialEmoji: entry.emojiPath,
        emojis: emojis,
        onSave: (msg, emoji) {
          _updateHistoryEntry(index, msg, emoji);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsBottomSheet(
        onExport: () async {
          final history = await _storage.loadHistory();
          await BackupService.exportBackup(history);
        },
        onImport: () async {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = tz.getLocation(_selectedTimezone);
    final now = tz.TZDateTime.now(location);
    final String formattedDate = DateFormat('EEEE, MMM d').format(now);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.fondoSoft,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _showSettings(context),
                        child: SvgPicture.asset(
                          AppAssets.featureIcons['Settings']!,
                          width: 28,
                          colorFilter: const ColorFilter.mode(
                              AppColors.textoOscuro, BlendMode.srcIn),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showTimezoneDialog,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: AppColors.rosaFuerte,
                              fontSize: width * 0.08,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text('How do you feel today?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: width * 0.15,
                                color: AppColors.textoOscuro,
                                height: 0.8)),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _textController,
                          style: const TextStyle(
                            color: AppColors.textoOscuro,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: "Let it be all out...",
                            hintStyle: TextStyle(
                              color: AppColors.rosaFuerte.withOpacity(0.8),
                            ),
                            filled: true,
                            fillColor: AppColors.naranjaPiel,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    color: AppColors.rosaFuerte, width: 2)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    color: AppColors.rosaFuerte, width: 2)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: AppColors.rosaFuerte.withOpacity(0.5),
                                  width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        StrokeText(
                            text: 'You prefer no words?',
                            fontSize: width * 0.12,
                            color: AppColors.rosaFuerte,
                            strokeColor: AppColors.textoOscuro),
                        Expanded(
                          child: MoodSelectorGrid(
                            emojis: emojis,
                            onEmojiSelected: _saveMood,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          HistoryBottomSheet(
            entries: _myHistory,
            selectedTimezone: _selectedTimezone,
            onEdit: (index, entry) => _showEditDialog(index, entry),
          ),
          if (_showOnboarding) OnboardingOverlay(onFinish: _closeOnboarding),
        ],
      ),
    );
  }
}
