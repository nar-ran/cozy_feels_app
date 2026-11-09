import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService extends ChangeNotifier {
  static final SecurityService instance = SecurityService._();
  SecurityService._();

  static const String _prefSecurityEnabled = 'security_lock_enabled';
  static const String _prefPinCode = 'security_pin_code';

  bool _isSecurityEnabled = false;
  String? _savedPin;
  bool _isLocked = false;

  bool get isSecurityEnabled => _isSecurityEnabled;
  bool get hasPin => _savedPin != null && _savedPin!.isNotEmpty;
  bool get isLocked => _isSecurityEnabled && hasPin && _isLocked;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSecurityEnabled = prefs.getBool(_prefSecurityEnabled) ?? false;
    _savedPin = prefs.getString(_prefPinCode);

    if (_isSecurityEnabled && hasPin) {
      _isLocked = true;
    }

    notifyListeners();
  }

  void lock() {
    if (_isSecurityEnabled && hasPin && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void unlock() {
    if (_isLocked) {
      _isLocked = false;
      notifyListeners();
    }
  }

  bool verifyPin(String enteredPin) {
    if (_savedPin == null) return false;
    final isCorrect = _savedPin == enteredPin;
    if (isCorrect) {
      unlock();
    }
    return isCorrect;
  }

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    _savedPin = newPin;
    await prefs.setString(_prefPinCode, newPin);
    notifyListeners();
  }

  Future<void> setSecurityEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isSecurityEnabled = enabled;
    await prefs.setBool(_prefSecurityEnabled, enabled);
    if (!enabled) {
      _isLocked = false;
    }
    notifyListeners();
  }
}
