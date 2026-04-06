import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check GPS
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showMessage(context, "Enable location service");
        return null;
      }
    }

    // Check permission
    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted == PermissionStatus.deniedForever) {
      _showDialog(context);
      return null;
    }

    if (permissionGranted != PermissionStatus.granted) {
      _showMessage(context, "Permission denied");
      return null;
    }

    try {
      return await location.getLocation();
    } catch (e) {
      _showMessage(context, "Failed to get location");
      return null;
    }
  }

  static void _showMessage(BuildContext? context, String msg) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  static void _showDialog(BuildContext? context) {
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Location permanently denied. Enable from settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
