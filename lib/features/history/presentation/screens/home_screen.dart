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
    final savedTimezone = prefs.getString('selected_timezone');

    setState(() {
      if (historyJson != null) {
        _myHistory.addAll(
            historyJson.map((json) => HistoryEntry.fromJson(jsonDecode(json))));
      }
      if (savedTimezone != null) {
        _selectedTimezone = savedTimezone;
      }
    });
  }

  Future<void> _saveTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_timezone', timezone);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _myHistory.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('history', historyJson);
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
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
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
                StrokeText(
                  text: 'Select Zone',
                  fontSize: width * 0.08,
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
                            _saveTimezone(entry.value);
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
                                      fontSize: width * 0.04,
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
                                    fontSize: width * 0.035,
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

  void _showEditDialog(int index, HistoryEntry entry) {
    final TextEditingController editController =
        TextEditingController(text: entry.message);
    String selectedEmoji = entry.emojiPath;
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(entry.date);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final width = MediaQuery.of(context).size.width;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Fecha
                      StrokeText(
                        text: formattedDate,
                        fontSize: width * 0.08,
                        color: AppColors.rosaFuerte,
                        strokeColor: AppColors.textoOscuro,
                      ),
                      const SizedBox(height: 25),

                      // 2. Grid de Emojis
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          physics: const NeverScrollableScrollPhysics(),
                          children: emojis.map((e) {
                            final isSelected = selectedEmoji == e.value;
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedEmoji = e.value),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.naranjaPiel
                                      : Colors.transparent,
                                ),
                                padding: EdgeInsets.all(width * 0.01),
                                child: SvgPicture.asset(
                                  e.value,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.textoOscuro,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 3. Cuadro de texto
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.naranjaPiel,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.rosaFuerte, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: TextField(
                            controller: editController,
                            maxLines: 4,
                            style: TextStyle(
                              color: AppColors.textoOscuro,
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 4. Botón Guardar
                      GestureDetector(
                        onTap: () {
                          _updateHistoryEntry(
                              index, editController.text, selectedEmoji);
                          Navigator.pop(context);
                        },
                        child: Text("Save Changes",
                            style: TextStyle(
                                fontSize: width * 0.07,
                                color: AppColors.rosaFuerte,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _showTimezoneDialog,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: AppColors.rosaFuerte,
                            fontSize: width * 0.09,
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
                                  padding: EdgeInsets.all(width * 0.01),
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
          HistoryBottomSheet(
            entries: _myHistory,
            onEdit: (index, entry) => _showEditDialog(index, entry),
          ),
        ],
      ),
    );
  }
}
