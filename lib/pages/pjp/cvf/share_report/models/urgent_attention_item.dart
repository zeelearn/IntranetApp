class UrgentAttentionItem {
  UrgentAttentionItem({
    this.areaOfConcern = '',
    this.timeline = '',
  });

  String areaOfConcern;
  String timeline;

  Map<String, dynamic> toJson() => {
        'AreaOfConcern': areaOfConcern.trim(),
        'Timeline': timeline.trim(),
      };

  /// Send API object: `{ "aoc": "...", "tl": "..." }`.
  Map<String, String>? toApiObject() {
    final area = areaOfConcern.trim();
    final time = timeline.trim();
    if (area.isEmpty && time.isEmpty) return null;
    return {
      'aoc': area,
      'tl': time,
    };
  }

  /// Legacy / preview string: `"Infrastructure – 7 Days"`.
  String toApiString() {
    final area = areaOfConcern.trim();
    final time = timeline.trim();
    if (area.isEmpty && time.isEmpty) return '';
    if (time.isEmpty) return area;
    if (area.isEmpty) return time;
    return '$area – $time';
  }

  factory UrgentAttentionItem.fromApiString(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return UrgentAttentionItem();
    final separators = [' – ', ' - ', ' –', '– ', ' — '];
    for (final sep in separators) {
      final idx = text.indexOf(sep);
      if (idx > 0) {
        return UrgentAttentionItem(
          areaOfConcern: text.substring(0, idx).trim(),
          timeline: text.substring(idx + sep.length).trim(),
        );
      }
    }
    return UrgentAttentionItem(areaOfConcern: text);
  }

  factory UrgentAttentionItem.fromApiObject(Map<String, dynamic> map) {
    return UrgentAttentionItem(
      areaOfConcern: (map['aoc'] ??
              map['AreaOfConcern'] ??
              map['areaOfConcern'] ??
              map['Area'] ??
              '')
          .toString()
          .trim(),
      timeline: (map['tl'] ?? map['Timeline'] ?? map['timeline'] ?? '')
          .toString()
          .trim(),
    );
  }
}
