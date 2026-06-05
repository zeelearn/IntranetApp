import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    try {
      final location = Location();

      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return null;
      }

      // On web, checking for permissions via hasPermission() can fail with a TypeError
      // regarding PermissionDescriptor on some browsers. To avoid hanging the UI,
      // we skip explicit checks and call getLocation() directly.
      // The browser will manage the permission prompt if needed.
      return await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
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
