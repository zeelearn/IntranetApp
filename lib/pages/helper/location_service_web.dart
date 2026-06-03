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

      // Check and request permissions using the cross-platform package.
      // Some browsers can throw when the Permissions API is queried;
      // guard against that and fall back to requesting permission.
      PermissionStatus permissionStatus;
      try {
        permissionStatus = await location.hasPermission();
      } catch (e) {
        print('location.hasPermission() failed on web: $e');
        try {
          permissionStatus = await location.requestPermission();
        } catch (e2) {
          print('location.requestPermission() also failed on web: $e2');
          _showMessage(context);
          return null;
        }
      }

      if (permissionStatus == PermissionStatus.denied) {
        try {
          permissionStatus = await location.requestPermission();
        } catch (e) {
          print('requestPermission failed: $e');
          _showMessage(context);
          return null;
        }
      }

      if (permissionStatus != PermissionStatus.granted) {
        _showMessage(context);
        return null;
      }

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
