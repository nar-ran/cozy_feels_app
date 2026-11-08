import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/history_filter_service.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/filters/history_filter_chips_bar.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/filters/history_search_bar.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/tags/tag_chip.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class HistoryBottomSheet extends StatefulWidget {
  final List<HistoryEntry> entries;
  final String selectedTimezone;
  final Function(int index, HistoryEntry entry) onEdit;

  const HistoryBottomSheet({
    super.key,
    required this.entries,
    required this.selectedTimezone,
    required this.onEdit,
  });

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  late final TextEditingController _searchController;
  HistoryFilterCriteria _criteria = HistoryFilterCriteria.empty;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _criteria = HistoryFilterCriteria.empty;
    });
  }

  String _getFixedPath(String originalPath) {
    if (originalPath.contains('/feelings/')) {
      return originalPath;
    }
    return originalPath.replaceAll(
      'assets/icons/svg/',
      'assets/icons/svg/feelings/',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final double emojiSize = width * 0.1;

    final availableTags = <String>{
      for (final entry in widget.entries) ...entry.tags,
    }.toList();

    final filteredEntries = HistoryFilterService.filterEntries(
      entries: widget.entries,
      criteria: _criteria,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.14,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.naranjaPiel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Cabecera fija con Handle, Título, Buscador y Filtros
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.fondoSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: StrokeText(
                        text: l10n.history_title,
                        fontSize: width * 0.12,
                        color: AppColors.rosaFuerte,
                        strokeColor: AppColors.strokeColor,
                      ),
                    ),
                    if (widget.entries.isNotEmpty) ...[
                      // Barra de búsqueda
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: HistorySearchBar(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _criteria = _criteria.copyWith(searchQuery: val);
                            });
                          },
                          onClear: () {
                            _searchController.clear();
                            setState(() {
                              _criteria = _criteria.copyWith(searchQuery: '');
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Carrusel de chips de filtro
                      HistoryFilterChipsBar(
                        criteria: _criteria,
                        availableTags: availableTags,
                        onCriteriaChanged: (newCriteria) {
                          setState(() => _criteria = newCriteria);
                        },
                      ),

                      // Indicador de filtros activos y botón de limpiar
                      if (_criteria.isActive) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.history_filter_results_count(
                                  filteredEntries.length,
                                  widget.entries.length,
                                ),
                                style: TextStyle(
                                  fontFamily: 'Dongle',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoOscuro
                                      .withValues(alpha: 0.75),
                                  height: 1.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: _clearAllFilters,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_alt_off_rounded,
                                      size: 15,
                                      color: AppColors.rosaFuerte,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.history_filter_clear,
                                      style: TextStyle(
                                        fontFamily: 'Dongle',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.rosaFuerte,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),

              // Lista de resultados o estados vacíos
              if (widget.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      l10n.history_empty_state,
                      style: TextStyle(
                        color: AppColors.textoOscuro,
                        fontFamily: 'Dongle',
                        fontSize: width * 0.06,
                      ),
                    ),
                  ),
                )
              else if (filteredEntries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 50,
                            color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.history_filter_no_results,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  AppColors.textoOscuro.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _clearAllFilters,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              l10n.history_filter_clear,
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.rosaFuerte,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = filteredEntries[index];

                        // Zona horaria y traducción de fecha
                        final location = tz.getLocation(widget.selectedTimezone);
                        final dateInZone =
                            tz.TZDateTime.from(entry.date, location);

                        final String locale =
                            Localizations.localeOf(context).languageCode;

                        var formattedDate = DateFormat('MMMM dd, yyyy', locale)
                            .format(dateInZone);

                        if (formattedDate.isNotEmpty) {
                          formattedDate = formattedDate[0].toUpperCase() +
                              formattedDate.substring(1);
                        }

                        // Localizar el índice original en la lista general para edición segura
                        final originalIndex = widget.entries.indexOf(entry);

                        return GestureDetector(
                          onTap: () => widget.onEdit(
                            originalIndex != -1 ? originalIndex : index,
                            entry,
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      _getFixedPath(entry.emojiPath),
                                      width: emojiSize,
                                      height: emojiSize,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.emojiColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    if (index != filteredEntries.length - 1)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColors.textoOscuro
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: width * 0.07,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textoOscuro,
                                            height: 1.2,
                                          ),
                                        ),
                                        Text(
                                          entry.message.isEmpty
                                              ? l10n.history_no_words
                                              : entry.message,
                                          style: TextStyle(
                                            fontSize: width * 0.055,
                                            color: AppColors.textoOscuro
                                                .withValues(alpha: 0.7),
                                            height: 1.1,
                                          ),
                                        ),
                                        if (entry.tags.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 5,
                                            runSpacing: 4,
                                            children: entry.tags
                                                .map(
                                                  (t) => TagChip(
                                                    tagId: t,
                                                    isCompact: true,
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredEntries.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        );
      },
    );
  }
}
