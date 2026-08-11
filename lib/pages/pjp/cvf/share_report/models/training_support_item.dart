class TrainingSupportItem {
  TrainingSupportItem({this.details = ''});

  String details;

  Map<String, dynamic> toJson() => {
        'Details': details.trim(),
      };
}
