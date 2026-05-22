import 'package:Intranet/api/response/pjp/pjplistresponse.dart';

class PredictionEngine {
  static List<GetDetailedPJP> recommend(List<GetDetailedPJP> visits) {
    visits.sort((a, b) => a.visitTime.compareTo(b.visitTime));

    return visits.where((v) => v.Status != 'Completed').take(5).toList();
  }
}
