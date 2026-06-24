import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
// imports trimmed: utils and toastUtility are unused here
import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart'
    if (dart.library.io) 'location_service_mobile.dart';

class LocationHelper {
  static isLocationPermission(BuildContext context) async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    try {
      permissionGranted = await location.hasPermission();
    } catch (e) {
      // Some browsers' Permissions API can throw when used this way
      // (e.g. PermissionDescriptor.name undefined). Fall back to
      // requesting permission where possible, or return false.
      try {
        permissionGranted = await location.requestPermission();
      } catch (e2) {
        return false;
      }
    }

    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      return false;
    }
    return true;
  }

  static Future<LocationData?> getLocation(BuildContext? context) {
    return LocationServiceImpl.getLocation(context);
  }

  /* static getLocation(BuildContext? context) async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted == PermissionStatus.deniedForever) {
        if (context != null) {
          bool? isAllowed = await Utility.openPermisisonSettings(context);
          if (!(isAllowed ?? false)) {
            ToastUtility.showWarning(
                msg: 'Location permission is required to access this feature');
            return;
          }
        }
      } else if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    return locationData;
  } */
}
