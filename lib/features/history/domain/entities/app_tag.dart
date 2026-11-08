import 'package:flutter/material.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class AppTag {
  final String id;
  final IconData icon;

  const AppTag({
    required this.id,
    required this.icon,
  });

  /// Lista fija de etiquetas predeterminadas
  static const List<AppTag> predefinedTags = [
    AppTag(id: 'work', icon: Icons.work_outline_rounded),
    AppTag(id: 'relationship', icon: Icons.favorite_border_rounded),
    AppTag(id: 'family', icon: Icons.cottage_outlined),
    AppTag(id: 'sleep', icon: Icons.bedtime_outlined),
    AppTag(id: 'study', icon: Icons.menu_book_rounded),
    AppTag(id: 'health', icon: Icons.spa_outlined),
    AppTag(id: 'leisure', icon: Icons.sports_esports_outlined),
    AppTag(id: 'social', icon: Icons.local_cafe_outlined),
  ];

  static IconData getIconForTag(String tagId) {
    for (final tag in predefinedTags) {
      if (tag.id == tagId) return tag.icon;
    }
    return Icons.label_outline_rounded;
  }

  static String getLabelForTag(String tagId, AppLocalizations l10n) {
    switch (tagId) {
      case 'work':
        return l10n.tag_work;
      case 'relationship':
        return l10n.tag_relationship;
      case 'family':
        return l10n.tag_family;
      case 'sleep':
        return l10n.tag_sleep;
      case 'study':
        return l10n.tag_study;
      case 'health':
        return l10n.tag_health;
      case 'leisure':
        return l10n.tag_leisure;
      case 'social':
        return l10n.tag_social;
      default:
        return tagId;
    }
  }

  static bool isPredefined(String tagId) {
    return predefinedTags.any((t) => t.id == tagId);
  }
}
