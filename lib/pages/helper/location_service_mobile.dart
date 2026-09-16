import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    BuildContext? effectiveContext = (context != null && context.mounted) ? context : Get.context;
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check GPS
    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showMessage(effectiveContext, "Enable location service");
          return null;
        }
      }
    } catch (e) {
      Get.log("Location service error: $e");
    }

    // Check permission
    try {
      permissionGranted = await location.hasPermission();
      Get.log("Permission status: $permissionGranted - ${effectiveContext?.mounted}");

      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        _showMessage(
          effectiveContext,
          "Location permission is permanently denied. Enable from settings.",
        );
        return null;
      }

      if (permissionGranted != PermissionStatus.granted) {
        _showMessage(effectiveContext, "Location permission denied");
        return null;
      }
    } catch (e) {
      Get.log("Permission error: $e");
      return null;
    }

    try {
      return await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Location request timed out");
        },
      );
    } catch (e) {
      _showMessage(effectiveContext, "Failed to get location");
      return null;
    }
  }

  static void _showMessage(BuildContext? context, String msg) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } else {
      Get.snackbar(
        "Location",
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
