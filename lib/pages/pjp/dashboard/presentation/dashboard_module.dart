import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VisitModel {
  final String franchiseeName;
  final String address;
  final DateTime visitDateTime;
  final double latitude;
  final double longitude;
  final String purpose;

  VisitModel({
    required this.franchiseeName,
    required this.address,
    required this.visitDateTime,
    required this.latitude,
    required this.longitude,
    required this.purpose,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late GoogleMapController mapController;

  final List<VisitModel> visits = [
    VisitModel(
      franchiseeName: "Ankurum Nazira Sivasagar",
      address: "Sivasagar, Assam",
      visitDateTime: DateTime(2025, 7, 29, 12, 00),
      latitude: 16.6792565,
      longitude: 74.216429,
      purpose: "Academic Support Visit",
    ),
    VisitModel(
      franchiseeName: "Dadar Railway Station",
      address: "Dadar, Mumbai",
      visitDateTime: DateTime(2026, 7, 29, 14, 30),
      latitude: 19.0178,
      longitude: 72.8478,
      purpose: "Meeting",
    ),
  ];

  Set<Marker> _buildMarkers() {
    return visits.map((visit) {
      return Marker(
        markerId: MarkerId(visit.franchiseeName),
        position: LatLng(visit.latitude, visit.longitude),
        infoWindow: InfoWindow(
          title: visit.franchiseeName,
          snippet:
              "${DateFormat('hh:mm a').format(visit.visitDateTime)} - ${visit.purpose}",
        ),
      );
    }).toSet();
  }

  Set<Polyline> _buildPolyline() {
    return {
      Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.blue,
        width: 5,
        points: visits.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      ),
    };
  }

  double calculateTotalDistance() {
    double total = 0;
    for (int i = 0; i < visits.length - 1; i++) {
      total += _haversine(
        visits[i].latitude,
        visits[i].longitude,
        visits[i + 1].latitude,
        visits[i + 1].longitude,
      );
    }
    return total;
  }

  double _haversine(lat1, lon1, lat2, lon2) {
    const R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Map<String, List<VisitModel>> groupByDate() {
    Map<String, List<VisitModel>> map = {};
    for (var visit in visits) {
      String date = DateFormat('yyyy-MM-dd').format(visit.visitDateTime);
      map.putIfAbsent(date, () => []);
      map[date]!.add(visit);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDate();
    final totalDistance = calculateTotalDistance();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Route Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// KPI Section
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _kpiCard("Total Visits", visits.length.toString()),
                  _kpiCard("Total Distance",
                      "${totalDistance.toStringAsFixed(2)} km"),
                ],
              ),
            ),

            /// Map Section
            SizedBox(
              height: 350,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(visits.first.latitude, visits.first.longitude),
                  zoom: 12,
                ),
                markers: _buildMarkers(),
                polylines: _buildPolyline(),
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),
            ),

            /// Timeline Section
            Expanded(
              child: ListView(
                children: grouped.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      "Date: ${entry.key}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value
                        .map((visit) => ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(visit.franchiseeName),
                              subtitle: Text(
                                  "${DateFormat('hh:mm a').format(visit.visitDateTime)}\n${visit.address}"),
                            ))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title),
      ],
    );
  }
}
