import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteOptimizer {
  static List<LatLng> optimize(List<LatLng> points) {
    if (points.length < 3) return points;

    List<LatLng> route = List.from(points);
    bool improvement = true;

    while (improvement) {
      improvement = false;
      for (int i = 1; i < route.length - 2; i++) {
        for (int j = i + 1; j < route.length - 1; j++) {
          if (_distance(route[i - 1], route[i]) +
                  _distance(route[j], route[j + 1]) >
              _distance(route[i - 1], route[j]) +
                  _distance(route[i], route[j + 1])) {
            route.replaceRange(i, j + 1, route.sublist(i, j + 1).reversed);
            improvement = true;
          }
        }
      }
    }

    return route;
  }

  static double _distance(LatLng a, LatLng b) =>
      sqrt(pow(a.latitude - b.latitude, 2) + pow(a.longitude - b.longitude, 2));
}
