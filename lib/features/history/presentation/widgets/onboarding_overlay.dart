import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingOverlay({super.key, required this.onFinish});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _stepIndex = 1;

  void _nextStep() {
    setState(() {
      if (_stepIndex < 3) {
        _stepIndex++;
      } else {
        widget.onFinish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.fondoSoft.withOpacity(0.89),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StrokeText(
              text: l10n.onboarding_guide_step(_stepIndex, 3),
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.textoOscuro,
            ),
            const SizedBox(height: 40),

            // Contenido dinámico según el paso
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(_stepIndex, width),
            ),

            const SizedBox(height: 60),

            GestureDetector(
              onTap: _nextStep,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.rosaFuerte.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: AppColors.textoOscuro.withOpacity(0.3),
                      width: 1.5),
                ),
                child: Text(
                  _stepIndex < 3 ? l10n.onboarding_next : l10n.onboarding_finish,
                  style: TextStyle(
                    color: AppColors.textoOscuro,
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int step, double width) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (step) {
      case 1:
        return _onboardingStep(
          l10n.onboarding_step1,
          Icons.auto_awesome,
          width,
          key: const ValueKey(1),
        );
      case 2:
        return _onboardingStep(
          l10n.onboarding_step2,
          Icons.history_edu,
          width,
          key: const ValueKey(2),
        );
      case 3:
        return _onboardingStep(
          l10n.onboarding_step3,
          Icons.language,
          width,
          key: const ValueKey(3),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _onboardingStep(String text, IconData icon, double width,
      {required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Icon(icon,
              color: AppColors.rosaFuerte.withOpacity(0.8), size: width * 0.1),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textoOscuro,
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
