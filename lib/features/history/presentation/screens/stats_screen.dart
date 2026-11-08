import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/stats_service.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/dominant_mood_card.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/mood_distribution_card.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/stats_empty_view.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/stats_period_selector.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/streak_card.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/stats/top_tags_card.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  final List<HistoryEntry> entries;
  final String selectedTimezone;
  final VoidCallback onOpenSettings;
  final VoidCallback onTimezoneTap;

  const StatsScreen({
    super.key,
    required this.entries,
    required this.selectedTimezone,
    required this.onOpenSettings,
    required this.onTimezoneTap,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    // Obtener fecha actual formateada en la zona horaria seleccionada
    final location = tz.getLocation(widget.selectedTimezone);
    final now = tz.TZDateTime.now(location);
    final String locale = Localizations.localeOf(context).languageCode;
    var formattedDate = DateFormat('EEEE, MMM d', locale).format(now);

    if (formattedDate.isNotEmpty) {
      formattedDate =
          formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    formattedDate = formattedDate.split(' ').map((word) {
      if (word.length > 1) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');

    // Calcular estadísticas
    final summary = StatsService.calculateSummary(
      allEntries: widget.entries,
      period: _selectedPeriod,
      selectedTimezone: widget.selectedTimezone,
    );

    return Scaffold(
      backgroundColor: AppColors.fondoSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onOpenSettings,
                    child: SvgPicture.asset(
                      AppAssets.featureIcons['Settings']!,
                      width: 28,
                      colorFilter: ColorFilter.mode(
                        AppColors.textoOscuro,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTimezoneTap,
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
            const SizedBox(height: 8),

            // Título
            StrokeText(
              text: l10n.stats_title,
              fontSize: width * 0.13,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),
            const SizedBox(height: 12),

            // Selector de Período (Semana / Mes / Todo)
            StatsPeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
            ),
            const SizedBox(height: 16),

            // Contenido con Scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Tarjeta de Racha (Siempre visible para motivar)
                    StreakCard(
                      currentStreak: summary.currentStreak,
                      bestStreak: summary.bestStreak,
                    ),
                    const SizedBox(height: 14),

                    // Si no hay registros en el período
                    if (summary.isEmpty)
                      const StatsEmptyView()
                    else ...[
                      // Tarjeta de Emoción Predominante
                      if (summary.dominantMood != null) ...[
                        DominantMoodCard(
                          dominantMood: summary.dominantMood!,
                          count: summary.moodCounts[summary.dominantMood!] ?? 0,
                          percentage:
                              summary.moodPercentages[summary.dominantMood!] ??
                                  0.0,
                          totalEntries: summary.totalEntries,
                          activeDays: summary.activeDays,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Tarjeta de Balance Emocional
                      MoodDistributionCard(
                        moodCounts: summary.moodCounts,
                        moodPercentages: summary.moodPercentages,
                        totalEntries: summary.totalEntries,
                      ),
                      const SizedBox(height: 14),

                      // Tarjeta de Etiquetas Más Frecuentes
                      TopTagsCard(topTags: summary.topTags),
                      const SizedBox(height: 14),
                    ],

                    // Espacio inferior para que el contenido no quede tapado por la barra de navegación
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
