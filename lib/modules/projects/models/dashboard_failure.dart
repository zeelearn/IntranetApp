enum DashboardFailureType {
  timeout,
  noInternet,
  unauthorized,
  forbidden,
  server,
  invalidJson,
  empty,
  unknown,
}

class DashboardFailure implements Exception {
  const DashboardFailure({
    required this.type,
    required this.message,
  });

  final DashboardFailureType type;
  final String message;

  @override
  String toString() => 'DashboardFailure($type): $message';
}
