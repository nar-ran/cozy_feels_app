import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/security/security_service.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

enum PinSetupStep {
  verifyCurrent,
  enterNew,
  confirmNew,
}

class PinSetupDialog extends StatefulWidget {
  final bool isChangingPin;

  const PinSetupDialog({
    super.key,
    this.isChangingPin = false,
  });

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  late PinSetupStep _step;
  String _currentInput = '';
  String _firstNewPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _step = widget.isChangingPin
        ? PinSetupStep.verifyCurrent
        : PinSetupStep.enterNew;
  }

  void _onNumberTap(int number) {
    if (_currentInput.length < 4) {
      setState(() {
        _errorMessage = null;
        _currentInput += number.toString();
      });

      if (_currentInput.length == 4) {
        _handleStepCompletion();
      }
    }
  }

  void _onBackspace() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  Future<void> _handleStepCompletion() async {
    final l10n = AppLocalizations.of(context)!;

    switch (_step) {
      case PinSetupStep.verifyCurrent:
        final isValid = SecurityService.instance.verifyPin(_currentInput);
        if (isValid) {
          setState(() {
            _step = PinSetupStep.enterNew;
            _currentInput = '';
          });
        } else {
          setState(() {
            _errorMessage = l10n.security_incorrect_pin;
            _currentInput = '';
          });
        }
        break;

      case PinSetupStep.enterNew:
        setState(() {
          _firstNewPin = _currentInput;
          _step = PinSetupStep.confirmNew;
          _currentInput = '';
        });
        break;

      case PinSetupStep.confirmNew:
        if (_currentInput == _firstNewPin) {
          await SecurityService.instance.setPin(_firstNewPin);
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = l10n.security_pin_mismatch;
            _step = PinSetupStep.enterNew;
            _currentInput = '';
            _firstNewPin = '';
          });
        }
        break;
    }
  }

  Widget _buildKeypadButton(int number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.naranjaPiel.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.rosaFuerte.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 34,
            height: 1.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textoOscuro,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    String title;
    String subtitle;

    if (widget.isChangingPin) {
      switch (_step) {
        case PinSetupStep.verifyCurrent:
          title = l10n.security_change_pin;
          subtitle = l10n.security_enter_current_pin;
          break;
        case PinSetupStep.enterNew:
          title = l10n.security_change_pin;
          subtitle = l10n.security_enter_new_pin;
          break;
        case PinSetupStep.confirmNew:
          title = l10n.security_confirm_pin_title;
          subtitle = l10n.security_reenter_pin;
          break;
      }
    } else {
      switch (_step) {
        case PinSetupStep.enterNew:
        case PinSetupStep.verifyCurrent:
          title = l10n.security_setup_pin_title;
          subtitle = l10n.security_create_pin_desc;
          break;
        case PinSetupStep.confirmNew:
          title = l10n.security_confirm_pin_title;
          subtitle = l10n.security_reenter_pin;
          break;
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.rosaFuerte,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StrokeText(
                    text: title,
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
                  onPressed: () => Navigator.pop(context, false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textoOscuro.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 4 Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _currentInput.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.rosaFuerte : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _errorMessage != null
                          ? Colors.redAccent
                          : AppColors.rosaFuerte,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            // Error text
            SizedBox(
              height: 24,
              child: _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            // Keypad
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton(1),
                    _buildKeypadButton(2),
                    _buildKeypadButton(3),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton(4),
                    _buildKeypadButton(5),
                    _buildKeypadButton(6),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKeypadButton(7),
                    _buildKeypadButton(8),
                    _buildKeypadButton(9),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 58, height: 58),
                    _buildKeypadButton(0),
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: IconButton(
                        icon: Icon(
                          Icons.backspace_outlined,
                          size: 22,
                          color: AppColors.textoOscuro.withValues(alpha: 0.8),
                        ),
                        onPressed: _onBackspace,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
