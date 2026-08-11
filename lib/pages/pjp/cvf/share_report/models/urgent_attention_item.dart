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
}
