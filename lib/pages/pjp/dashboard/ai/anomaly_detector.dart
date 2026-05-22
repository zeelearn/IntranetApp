import 'package:Intranet/api/response/pjp/pjplistresponse.dart';

class AnomalyDetector {
  static bool lowCompletion(List<GetDetailedPJP> visits) {
    int completed = visits.where((v) => v.Status == 'Completed').length;

    return (completed / visits.length) < 0.5;
  }

  // static bool abnormalDuration(List<GetDetailedPJP> visits) {
  //   return visits.any((v) => v.DurationMinutes < 5);
  // }
}
