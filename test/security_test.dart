import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cozy_feels_app/core/security/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SecurityService (PIN Lock)', () {
    test('is disabled by default and unlocked', () async {
      final security = SecurityService.instance;
      await security.init();

      expect(security.isSecurityEnabled, isFalse);
      expect(security.hasPin, isFalse);
      expect(security.isLocked, isFalse);
    });

    test('sets and verifies 4-digit PIN', () async {
      final security = SecurityService.instance;
      await security.init();

      await security.setPin('1234');
      expect(security.hasPin, isTrue);

      expect(security.verifyPin('9999'), isFalse);
      expect(security.verifyPin('1234'), isTrue);
    });

    test('locks when security is enabled and unlocks on valid PIN', () async {
      final security = SecurityService.instance;
      await security.init();

      await security.setPin('4321');
      await security.setSecurityEnabled(true);
      expect(security.isSecurityEnabled, isTrue);

      security.lock();
      expect(security.isLocked, isTrue);

      // PIN incorrecto no desbloquea
      expect(security.verifyPin('0000'), isFalse);
      expect(security.isLocked, isTrue);

      // PIN correcto desbloquea
      expect(security.verifyPin('4321'), isTrue);
      expect(security.isLocked, isFalse);
    });

    test('disabling security clears locked state', () async {
      final security = SecurityService.instance;
      await security.init();

      await security.setPin('1111');
      await security.setSecurityEnabled(true);
      security.lock();
      expect(security.isLocked, isTrue);

      await security.setSecurityEnabled(false);
      expect(security.isLocked, isFalse);
    });
  });
}
