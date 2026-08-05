import 'package:hive/hive.dart';

/// Persists per-CRM credential send cooldown (default 15 minutes).
class CredentialsCooldownStore {
  CredentialsCooldownStore({
    this.boxName = 'project_credentials_cooldown',
    this.cooldown = const Duration(minutes: 15),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final String boxName;
  final Duration cooldown;
  final DateTime Function() _clock;

  Box<int>? _box;

  static String keyFor(String crmId) => 'cred_cd_${crmId.trim()}';

  Future<Box<int>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<int>(boxName);
    return _box!;
  }

  /// Timestamp (ms since epoch) until which sending is blocked.
  Future<DateTime?> cooldownUntil(String crmId) async {
    final id = crmId.trim();
    if (id.isEmpty) return null;
    final box = await _ensureBox();
    final raw = box.get(keyFor(id));
    if (raw == null) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(raw);
    if (!_clock().isBefore(until)) {
      await box.delete(keyFor(id));
      return null;
    }
    return until;
  }

  Future<Duration?> remaining(String crmId) async {
    final until = await cooldownUntil(crmId);
    if (until == null) return null;
    final left = until.difference(_clock());
    if (left.isNegative || left == Duration.zero) return null;
    return left;
  }

  Future<bool> canSend(String crmId) async {
    return (await remaining(crmId)) == null;
  }

  Future<void> markSent(String crmId) async {
    final id = crmId.trim();
    if (id.isEmpty) return;
    final box = await _ensureBox();
    final until = _clock().add(cooldown);
    await box.put(keyFor(id), until.millisecondsSinceEpoch);
  }

  /// Pure helper for UI/tests without I/O.
  static Duration? remainingFromUntil(DateTime? until, {DateTime? now}) {
    if (until == null) return null;
    final left = until.difference(now ?? DateTime.now());
    if (left.isNegative || left == Duration.zero) return null;
    return left;
  }

  static String formatRemaining(Duration remaining) {
    final totalSeconds = remaining.inSeconds;
    if (totalSeconds <= 0) return '0s';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes <= 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }
}
