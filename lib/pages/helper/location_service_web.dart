import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    try {
      final permission = await html.window.navigator.permissions
          ?.query({'name': 'geolocation'});

      if (permission?.state == "denied") {
        _showMessage(context);
        return null;
      }

      html.Geoposition position =
          await html.window.navigator.geolocation.getCurrentPosition();
      return LocationData.fromMap({
        'latitude': position.coords?.latitude,
        'longitude': position.coords?.longitude,
        'speed': position.coords?.speed,
        'accuracy': position.coords?.accuracy,
        'altitude': position.coords?.altitude,
        'altitudeAccuracy': position.coords?.altitudeAccuracy,
        'heading': position.coords?.heading,
        'timestamp': position.timestamp,
      });
    } catch (e) {
      _showMessage(context);
      return null;
    }
  }

  static void _showMessage(BuildContext? context) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_off, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text("Location is blocked. Enable from browser settings."),
            ),
          ],
        ),
      ),
    );
  }
}
