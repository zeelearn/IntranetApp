class WorkingWellItem {
  WorkingWellItem({this.observation = ''});

  String observation;

  Map<String, dynamic> toJson() => {
        'Observation': observation.trim(),
      };
}
