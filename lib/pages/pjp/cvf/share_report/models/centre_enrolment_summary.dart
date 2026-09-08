/// Grade columns for branding / enrolment matrix.
class EnrolmentGradeCounts {
  EnrolmentGradeCounts({
    this.pg = '',
    this.nur = '',
    this.jrKg = '',
    this.srKg = '',
    this.mtPg = '',
    this.mtNur = '',
  });

  String pg;
  String nur;
  String jrKg;
  String srKg;
  String mtPg;
  String mtNur;

  static const gradeKeys = ['pg', 'nur', 'jrKg', 'srKg', 'mtPg', 'mtNur'];
  static const gradeLabels = ['PG', 'NUR', 'JR KG', 'SR KG', 'MT PG', 'MT NUR'];

  factory EnrolmentGradeCounts.zeros() => EnrolmentGradeCounts(
        pg: '0',
        nur: '0',
        jrKg: '0',
        srKg: '0',
        mtPg: '0',
        mtNur: '0',
      );

  factory EnrolmentGradeCounts.empty() => EnrolmentGradeCounts();

  String valueAt(int index) {
    switch (index) {
      case 0:
        return pg;
      case 1:
        return nur;
      case 2:
        return jrKg;
      case 3:
        return srKg;
      case 4:
        return mtPg;
      case 5:
        return mtNur;
      default:
        return '';
    }
  }

  void setAt(int index, String value) {
    switch (index) {
      case 0:
        pg = value;
        break;
      case 1:
        nur = value;
        break;
      case 2:
        jrKg = value;
        break;
      case 3:
        srKg = value;
        break;
      case 4:
        mtPg = value;
        break;
      case 5:
        mtNur = value;
        break;
    }
  }

  List<String> get values => [pg, nur, jrKg, srKg, mtPg, mtNur];

  bool get allFilled =>
      values.every((v) => v.trim().isNotEmpty);

  Map<String, dynamic> toJson() => {
        'pg': pg.trim(),
        'nur': nur.trim(),
        'jr': jrKg.trim(),
        'sr': srKg.trim(),
        'mtpg': mtPg.trim(),
        'mtnur': mtNur.trim(),
      };

  factory EnrolmentGradeCounts.fromJson(
    dynamic raw, {
    String fallback = '0',
  }) {
    if (raw is! Map) {
      return fallback == '0'
          ? EnrolmentGradeCounts.zeros()
          : EnrolmentGradeCounts.empty();
    }
    final json = Map<String, dynamic>.from(raw);
    String pick(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final t = json[k].toString().trim();
          if (t.isNotEmpty) return t;
        }
      }
      return fallback;
    }

    return EnrolmentGradeCounts(
      pg: pick(const ['pg', 'PG', 'PlayGroup']),
      nur: pick(const ['nur', 'NUR', 'Nursery']),
      jrKg: pick(const ['jr', 'jrKg', 'JRKG', 'JrKg']),
      srKg: pick(const ['sr', 'srKg', 'SRKG', 'SrKg']),
      mtPg: pick(const ['mtpg', 'mtPg', 'MTPG', 'MtPg']),
      mtNur: pick(const ['mtnur', 'mtNur', 'MTNUR', 'MtNur']),
    );
  }
}

/// Branding toggle + enrolment matrix (API + manual rows).
class CentreEnrolmentSummary {
  CentreEnrolmentSummary({
    this.brandingUpgraded = false,
    EnrolmentGradeCounts? enrolmentAy2025,
    EnrolmentGradeCounts? ackAy2026,
    EnrolmentGradeCounts? enrolmentAy2026,
    EnrolmentGradeCounts? headCount,
    EnrolmentGradeCounts? registerCount,
  })  : enrolmentAy2025 = enrolmentAy2025 ?? EnrolmentGradeCounts.zeros(),
        ackAy2026 = ackAy2026 ?? EnrolmentGradeCounts.zeros(),
        enrolmentAy2026 = enrolmentAy2026 ?? EnrolmentGradeCounts.zeros(),
        headCount = headCount ?? EnrolmentGradeCounts.empty(),
        registerCount = registerCount ?? EnrolmentGradeCounts.empty();

  bool brandingUpgraded;
  EnrolmentGradeCounts enrolmentAy2025;
  EnrolmentGradeCounts ackAy2026;
  EnrolmentGradeCounts enrolmentAy2026;
  EnrolmentGradeCounts headCount;
  EnrolmentGradeCounts registerCount;

  factory CentreEnrolmentSummary.defaults() => CentreEnrolmentSummary();

  Map<String, dynamic> toJson() => {
        'branding': brandingUpgraded,
        'ay2025': enrolmentAy2025.toJson(),
        'ack2026': ackAy2026.toJson(),
        'ay2026': enrolmentAy2026.toJson(),
        'hc': headCount.toJson(),
        'rc': registerCount.toJson(),
      };

  factory CentreEnrolmentSummary.fromJson(dynamic raw) {
    if (raw is! Map) return CentreEnrolmentSummary.defaults();
    final json = Map<String, dynamic>.from(raw);
    final brandingRaw = json['branding'] ??
        json['Branding'] ??
        json['CentreBrandingUpgraded'] ??
        json['isBrandingUpgraded'];
    var branding = false;
    if (brandingRaw is bool) {
      branding = brandingRaw;
    } else if (brandingRaw != null) {
      final t = brandingRaw.toString().trim().toLowerCase();
      branding = t == '1' || t == 'true' || t == 'yes' || t == 'y';
    }

    EnrolmentGradeCounts parseManual(dynamic value) {
      if (value == null) return EnrolmentGradeCounts.empty();
      return EnrolmentGradeCounts.fromJson(value, fallback: '');
    }

    return CentreEnrolmentSummary(
      brandingUpgraded: branding,
      enrolmentAy2025: EnrolmentGradeCounts.fromJson(
        json['ay2025'] ?? json['EnrolmentAy2025'] ?? json['enrolmentAy2025'],
      ),
      ackAy2026: EnrolmentGradeCounts.fromJson(
        json['ack2026'] ?? json['AckAy2026'] ?? json['ackAy2026'],
      ),
      enrolmentAy2026: EnrolmentGradeCounts.fromJson(
        json['ay2026'] ?? json['EnrolmentAy2026'] ?? json['enrolmentAy2026'],
      ),
      headCount: parseManual(json['hc'] ?? json['HeadCount'] ?? json['headCount']),
      registerCount:
          parseManual(json['rc'] ?? json['RegisterCount'] ?? json['registerCount']),
    );
  }
}
