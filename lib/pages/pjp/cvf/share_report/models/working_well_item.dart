class WorkingWellItem {
  WorkingWellItem({this.observation = ''});

  String observation;

  Map<String, dynamic> toJson() => {
        'Observation': observation.trim(),
      };

  /// API list item format for Send/Get PJPCVFEmail.
  String toApiString() => observation.trim();
}
