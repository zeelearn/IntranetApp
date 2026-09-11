import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'LocalConstant.dart';
import 'utils.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  DateTime? _suppressLockUntil;

  bool get isAuthenticating => _isAuthenticating;

  /// Returns true if app lock checks should be temporarily ignored
  /// (e.g. during an ongoing biometric prompt or right after dismissing it).
  bool get isLockSuppressed {
    if (_isAuthenticating) return true;
    if (_suppressLockUntil != null) {
      if (DateTime.now().isBefore(_suppressLockUntil!)) {
        return true;
      }
      _suppressLockUntil = null;
    }
    return false;
  }

  /// Temporarily suppress lifecycle resume locking for a duration.
  void suppressLockFor([Duration duration = const Duration(seconds: 4)]) {
    final target = DateTime.now().add(duration);
    if (_suppressLockUntil == null || target.isAfter(_suppressLockUntil!)) {
      _suppressLockUntil = target;
    }
  }

  /// Whether biometric auth is supported on the current platform.
  bool get isSupportedPlatform => !kIsWeb;

  /// Checks if the device has biometric hardware and capability.
  Future<bool> isBiometricsAvailable() async {
    if (!isSupportedPlatform) return false;
    try {
      final bool canAuthenticateWithBiometrics =
          await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('BiometricService: isBiometricsAvailable error: $e');
      return false;
    } catch (e) {
      debugPrint('BiometricService: isBiometricsAvailable error: $e');
      return false;
    }
  }

  /// Returns available biometric hardware types (fingerprint, face, etc.).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!isSupportedPlatform) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('BiometricService: getAvailableBiometrics error: $e');
      return [];
    } catch (e) {
      debugPrint('BiometricService: getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Returns a user-friendly label matching the device hardware.
  Future<String> getBiometricTypeLabel() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint) ||
        biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.weak)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris Scanner';
    }
    return 'Biometrics';
  }

  /// Whether the user has enabled the biometric app lock setting in Hive.
  Future<bool> isBiometricLockEnabled() async {
    if (!isSupportedPlatform) return false;
    try {
      final box = await Utility.openBox();
      final enabled = box.get(LocalConstant.KEY_BIOMETRIC_LOCK_ENABLED,
          defaultValue: false);
      if (enabled is bool) {
        return enabled;
      }
      return enabled.toString().toLowerCase() == 'true';
    } catch (e) {
      debugPrint('BiometricService: isBiometricLockEnabled error: $e');
      return false;
    }
  }

  /// Saves the user's preference for biometric app lock.
  Future<void> setBiometricLockEnabled(bool enabled) async {
    try {
      final box = await Utility.openBox();
      await box.put(LocalConstant.KEY_BIOMETRIC_LOCK_ENABLED, enabled);
    } catch (e) {
      debugPrint('BiometricService: setBiometricLockEnabled error: $e');
    }
  }

  /// Prompts the system biometric dialog.
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to unlock the Intranet app',
    bool biometricOnly = false,
  }) async {
    if (!isSupportedPlatform) return true;
    if (_isAuthenticating) return false;

    _isAuthenticating = true;
    suppressLockFor(const Duration(seconds: 6));
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('BiometricService: authenticate PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('BiometricService: authenticate error: $e');
      return false;
    } finally {
      _isAuthenticating = false;
      suppressLockFor(const Duration(seconds: 4));
    }
  }

  /// Stops ongoing authentication if any.
  Future<void> cancelAuthentication() async {
    if (!isSupportedPlatform) return;
    try {
      await _auth.stopAuthentication();
    } catch (_) {}
    _isAuthenticating = false;
    suppressLockFor(const Duration(seconds: 2));
  }
}
