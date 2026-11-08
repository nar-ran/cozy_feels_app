import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/security/security_service.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _hasError = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberTap(int number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _hasError = false;
        _enteredPin += number.toString();
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = SecurityService.instance.verifyPin(_enteredPin);
    if (!success) {
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });
      _shakeController.forward(from: 0.0);
    }
  }

  Widget _buildKeypadButton(int number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.naranjaPiel.withValues(alpha: 0.75),
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
            fontSize: 38,
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.fondoSoft,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icono Candado Cozy
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.naranjaPiel.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.rosaFuerte.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 46,
                    color: AppColors.rosaFuerte,
                  ),
                ),

                const SizedBox(height: 16),

                StrokeText(
                  text: l10n.security_unlock_title,
                  fontSize: width * 0.09,
                  color: AppColors.rosaFuerte,
                  strokeColor: AppColors.strokeColor,
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.security_enter_pin,
                  style: TextStyle(
                    color: AppColors.textoOscuro.withValues(alpha: 0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // 4 Puntos del PIN animados con Shake en caso de error
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? AppColors.rosaFuerte
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hasError
                                ? Colors.redAccent
                                : AppColors.rosaFuerte,
                            width: 2.2,
                          ),
                          boxShadow: isFilled
                              ? [
                                  BoxShadow(
                                    color: AppColors.rosaFuerte
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // Mensaje de error
                SizedBox(
                  height: 22,
                  child: _hasError
                      ? Text(
                          l10n.security_incorrect_pin,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),

                const Spacer(flex: 1),

                // Teclado numérico
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton(4),
                        _buildKeypadButton(5),
                        _buildKeypadButton(6),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton(7),
                        _buildKeypadButton(8),
                        _buildKeypadButton(9),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Espacio vacío para balance
                        const SizedBox(
                          width: 66,
                          height: 66,
                        ),
                        _buildKeypadButton(0),
                        // Botón de Borrar
                        SizedBox(
                          width: 66,
                          height: 66,
                          child: IconButton(
                            icon: Icon(
                              Icons.backspace_outlined,
                              size: 24,
                              color:
                                  AppColors.textoOscuro.withValues(alpha: 0.8),
                            ),
                            onPressed: _onBackspace,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
