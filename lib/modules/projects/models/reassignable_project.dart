class ReassignableProject {
  const ReassignableProject({
    required this.id,
    required this.name,
    required this.status,
    required this.teamLabels,
    required this.ownerId,
    required this.ownerName,
  });

  final String id;
  final String name;
  final String status; // Active | In Progress | Pending
  final List<String> teamLabels;
  final String ownerId;
  final String ownerName;
}
