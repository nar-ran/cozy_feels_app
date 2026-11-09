import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/security/security_service.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'pin_setup_dialog.dart';

class SecuritySettingsDialog extends StatelessWidget {
  const SecuritySettingsDialog({super.key});

  Future<void> _handleToggleSecurity(
      BuildContext context, bool enable) async {
    final security = SecurityService.instance;

    if (enable) {
      if (!security.hasPin) {
        // Solicitar creación de PIN inicial
        final pinSet = await showDialog<bool>(
          context: context,
          builder: (context) => const PinSetupDialog(),
        );

        if (pinSet == true) {
          await security.setSecurityEnabled(true);
        }
      } else {
        await security.setSecurityEnabled(true);
      }
    } else {
      await security.setSecurityEnabled(false);
    }
  }

  Future<void> _handleChangePin(BuildContext context) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const PinSetupDialog(isChangingPin: true),
    );

    if (success == true && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.security_pin_updated),
          backgroundColor: AppColors.rosaFuerte,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return ListenableBuilder(
      listenable: SecurityService.instance,
      builder: (context, _) {
        final security = SecurityService.instance;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.fondoSoft,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.rosaFuerte.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.rosaFuerte,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StrokeText(
                        text: l10n.security_dialog_title,
                        fontSize: width * 0.07,
                        color: AppColors.rosaFuerte,
                        strokeColor: AppColors.strokeColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textoOscuro.withValues(alpha: 0.7),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Switch de Bloqueo con PIN
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.naranjaPiel.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.rosaFuerte.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.rosaFuerte,
                    title: Text(
                      l10n.security_enable_lock,
                      style: TextStyle(
                        color: AppColors.textoOscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      l10n.security_enable_lock_desc,
                      style: TextStyle(
                        color: AppColors.textoOscuro.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    value: security.isSecurityEnabled,
                    onChanged: (val) => _handleToggleSecurity(context, val),
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Botón para Cambiar PIN (solo visible si está habilitado y tiene PIN)
                if (security.isSecurityEnabled && security.hasPin)
                  OutlinedButton.icon(
                    onPressed: () => _handleChangePin(context),
                    icon: Icon(Icons.pin_rounded,
                        size: 20, color: AppColors.rosaFuerte),
                    label: Text(
                      l10n.security_change_pin,
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rosaFuerte,
                        height: 1.0,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
}
