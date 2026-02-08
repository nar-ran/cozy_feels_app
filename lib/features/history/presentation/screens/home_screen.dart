import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/history_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('history');
    if (historyJson != null) {
      setState(() {
        _myHistory.addAll(historyJson.map((json) => HistoryEntry.fromJson(jsonDecode(json))));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _myHistory.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('history', historyJson);
  }

  void _saveMood(String selectedEmojiPath) {
    setState(() {
      _myHistory.insert(
          0,
          HistoryEntry(
            date: DateTime.now(),
            message: _textController.text,
            emojiPath: selectedEmojiPath,
          ));
      _textController.clear();
    });
    _saveHistory();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

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
                    child: Text(formattedDate,
                        style: const TextStyle(color: AppColors.rosaFuerte, fontSize: 30, fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontSize: 60, color: AppColors.textoOscuro, height: 0.8)),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Let it be all out...",
                            filled: true,
                            fillColor: AppColors.naranjaPiel,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(color: AppColors.rosaFuerte, width: 2)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(color: AppColors.rosaFuerte, width: 2)),
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
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    colorFilter: const ColorFilter.mode(AppColors.textoOscuro, BlendMode.srcIn),
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