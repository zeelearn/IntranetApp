import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    BuildContext? effectiveContext = (context != null && context.mounted) ? context : Get.context;
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
      return await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Location request timed out");
        },
      );
    } catch (e) {
      _showMessage(effectiveContext);
      return null;
    }
  }

  static void _showMessage(BuildContext? context) {
    if (context != null && context.mounted) {
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
    } else {
      Get.snackbar(
        "Location",
        "Location is blocked. Enable from browser settings.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
