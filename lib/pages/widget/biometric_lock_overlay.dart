import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helper/LocalConstant.dart';
import '../helper/biometric_service.dart';
import '../helper/utils.dart';
import '../intro/intro.dart';
import '../utils/theme/colors/light_colors.dart';

/// Wraps the entire application to monitor lifecycle state and present
/// a full-screen biometric lock overlay when app is resumed or cold-started.
class BiometricLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const BiometricLifecycleWrapper({
    super.key,
    required this.child,
  });

  static BiometricLifecycleWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<BiometricLifecycleWrapperState>();
  }

  @override
  State<BiometricLifecycleWrapper> createState() =>
      BiometricLifecycleWrapperState();
}

class BiometricLifecycleWrapperState extends State<BiometricLifecycleWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      final box = await Utility.openBox();
      final firstName =
          box.get(LocalConstant.KEY_FIRST_NAME)?.toString() ?? '';
      final isLoggedIn =
          box.get(LocalConstant.KEY_ISLOGGEDIN, defaultValue: false);
      final hasLoginStatus =
          isLoggedIn == true || isLoggedIn.toString().toLowerCase() == 'true';
      return firstName.trim().isNotEmpty || hasLoginStatus;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInitialLock() async {
    if (!BiometricService.instance.isSupportedPlatform) return;
    final loggedIn = await _isUserLoggedIn();
    if (!loggedIn) return;

    final enabled = await BiometricService.instance.isBiometricLockEnabled();
    if (enabled && mounted) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!BiometricService.instance.isSupportedPlatform) return;

    // If an in-app biometric authentication is ongoing or recently finished,
    // do not track background/pause state.
    if (BiometricService.instance.isLockSuppressed) {
      _pausedTime = null;
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pausedTime ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final paused = _pausedTime;
      _pausedTime = null;

      // If already locked or auth is suppressed, ignore resume event
      if (_isLocked || BiometricService.instance.isLockSuppressed) {
        return;
      }

      if (paused != null) {
        final elapsed = DateTime.now().difference(paused);
        // Lock if backgrounded for more than 4 seconds
        if (elapsed.inSeconds >= 4) {
          _triggerResumeLock();
        }
      }
    }
  }

  Future<void> _triggerResumeLock() async {
    final loggedIn = await _isUserLoggedIn();
    if (!loggedIn) return;

    final enabled = await BiometricService.instance.isBiometricLockEnabled();
    if (enabled && mounted && !_isLocked) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  void unlock() {
    if (mounted) {
      BiometricService.instance.suppressLockFor(const Duration(seconds: 4));
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: BiometricLockOverlay(
                onAuthenticated: unlock,
              ),
            ),
          ),
      ],
    );
  }
}

class BiometricLockOverlay extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const BiometricLockOverlay({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<BiometricLockOverlay> createState() => _BiometricLockOverlayState();
}

class _BiometricLockOverlayState extends State<BiometricLockOverlay> {
  String _biometricLabel = 'Biometrics';
  String _userName = '';
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetailsAndAuthenticate();
  }

  Future<void> _loadDetailsAndAuthenticate() async {
    try {
      final box = await Utility.openBox();
      final firstName =
          box.get(LocalConstant.KEY_FIRST_NAME)?.toString() ?? '';
      final lastName = box.get(LocalConstant.KEY_LAST_NAME)?.toString() ?? '';
      final label = await BiometricService.instance.getBiometricTypeLabel();

      if (mounted) {
        setState(() {
          _userName = ('$firstName $lastName').trim();
          _biometricLabel = label;
        });
      }

      // Auto-trigger authentication with a short delay after mount
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted && !_isAuthenticating) {
        _triggerBiometricAuth();
      }
    } catch (e) {
      debugPrint('BiometricLockOverlay init error: $e');
    }
  }

  Future<void> _triggerBiometricAuth() async {
    if (_isAuthenticating || BiometricService.instance.isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final success = await BiometricService.instance.authenticate(
      localizedReason: 'Authenticate to access Zee Learn Intranet',
      biometricOnly: false,
    );

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (success) {
        BiometricService.instance.suppressLockFor(const Duration(seconds: 4));
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final box = await Utility.openBox();
    await box.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => IntroPage()),
        (route) => false,
      );
    }
  }

  IconData _getBiometricIcon() {
    if (_biometricLabel.toLowerCase().contains('face')) {
      return Icons.face_rounded;
    } else if (_biometricLabel.toLowerCase().contains('iris')) {
      return Icons.remove_red_eye_outlined;
    }
    return Icons.fingerprint_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation while locked
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // App Logo / Lock Header
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: LightColors.kDarkBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 44,
                      color: LightColors.kDarkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Intranet App Locked',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LightColors.kDarkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_userName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back, $_userName',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Please authenticate with $_biometricLabel to continue.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 18, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.red.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(flex: 2),
                // Biometric Unlock Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _triggerBiometricAuth,
                    icon: Icon(_getBiometricIcon(), size: 24),
                    label: Text(
                      _isAuthenticating
                          ? 'Authenticating...'
                          : 'Unlock with $_biometricLabel',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightColors.kDarkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Logout option
                TextButton(
                  onPressed: _handleLogout,
                  child: Text(
                    'Log Out / Switch Account',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
