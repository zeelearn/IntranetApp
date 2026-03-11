import 'dart:math';

import 'package:Intranet/api/response/pjp/pjplistresponse.dart';

class TerritoryClustering {
  static Map<int, List<GetDetailedPJP>> cluster(
      List<GetDetailedPJP> visits, int k) {
    List<List<double>> centroids =
        visits.take(k).map((v) => [v.Latitude, v.Longitude]).toList();

    Map<int, List<GetDetailedPJP>> clusters = {};

    for (int iteration = 0; iteration < 10; iteration++) {
      clusters.clear();

      for (var visit in visits) {
        int closest = 0;
        double minDist = double.infinity;

        for (int i = 0; i < centroids.length; i++) {
          double dist = sqrt(pow(visit.Latitude - centroids[i][0], 2) +
              pow(visit.Longitude - centroids[i][1], 2));

          if (dist < minDist) {
            minDist = dist;
            closest = i;
          }
        }

        clusters.putIfAbsent(closest, () => []).add(visit);
      }

      centroids = clusters.values.map((cluster) {
        double avgLat = cluster.map((e) => e.Latitude).reduce((a, b) => a + b) /
            cluster.length;

        double avgLng =
            cluster.map((e) => e.Longitude).reduce((a, b) => a + b) /
                cluster.length;

        return [avgLat, avgLng];
      }).toList();
    }

    return clusters;
  }
}
