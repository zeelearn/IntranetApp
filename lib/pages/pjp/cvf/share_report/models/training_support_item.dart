class TrainingSupportItem {
  TrainingSupportItem({this.details = ''});

  String details;

  Map<String, dynamic> toJson() => {
        'Details': details.trim(),
      };

  /// API list item format for Send/Get PJPCVFEmail.
  String toApiString() => details.trim();
}
