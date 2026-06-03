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
    print('in Permission');
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
      print('location.hasPermission() failed: $e');
      try {
        permissionGranted = await location.requestPermission();
      } catch (e2) {
        print('location.requestPermission() also failed: $e2');
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
    print('in Permission');
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    print('has Permission $permissionGranted');
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      print('request Permission 12 $permissionGranted');
      if (permissionGranted == PermissionStatus.deniedForever) {
        print('has Permission always denied');
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
    print('location is ');
    locationData = await location.getLocation();
    print(locationData);
    return locationData;
  } */
}
