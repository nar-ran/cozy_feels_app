import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/history_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('history');
    if (historyJson != null) {
      setState(() {
        _myHistory.addAll(
            historyJson.map((json) => HistoryEntry.fromJson(jsonDecode(json))));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _myHistory.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('history', historyJson);
  }

  void _saveMood(String selectedEmojiPath) {
    setState(() {
      _myHistory.insert(
          0,
          HistoryEntry(
            date: tz.TZDateTime.now(tz.getLocation(_selectedTimezone)),
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
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.fondoSoft,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.rosaFuerte, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StrokeText(
                  text: 'Select Zone',
                  fontSize: 35,
                  color: AppColors.rosaFuerte,
                  strokeColor: AppColors.textoOscuro,
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _timezoneMap.entries.map((entry) {
                        final isSelected = _selectedTimezone == entry.value;
                        final zoneLocation = tz.getLocation(entry.value);
                        final zoneNow = tz.TZDateTime.now(zoneLocation);
                        final timeString =
                            DateFormat('hh:mm a').format(zoneNow);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedTimezone = entry.value);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.rosaFuerte
                                  : AppColors.naranjaPiel,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: AppColors.rosaFuerte, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textoOscuro,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textoOscuro
                                            .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(), 
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = tz.getLocation(_selectedTimezone);
    final now = tz.TZDateTime.now(location);
    final String formattedDate = DateFormat('EEEE, MMM d').format(now);

    return Scaffold(
      backgroundColor: AppColors.fondoSoft,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _showTimezoneDialog,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: AppColors.rosaFuerte,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text('How do you feel today?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 60,
                                color: AppColors.textoOscuro,
                                height: 0.8)),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Let it be all out...",
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
                          ),
                        ),
                        const SizedBox(height: 30),
                        const StrokeText(
                            text: 'You prefer no words?',
                            fontSize: 50,
                            color: AppColors.rosaFuerte,
                            strokeColor: AppColors.textoOscuro),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: emojis.length,
                            itemBuilder: (context, index) {
                              final emoji = emojis[index];
                              return GestureDetector(
                                onTap: () => _saveMood(emoji.value),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    emoji.value,
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.textoOscuro, BlendMode.srcIn),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          HistoryBottomSheet(entries: _myHistory),
        ],
      ),
    );
  }
}
