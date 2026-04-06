import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:saathi/core/utility/toastUtility.dart';
import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart'
    if (dart.library.io) 'location_service_mobile.dart';

class LocationHelper {
  static isLocationPermission(BuildContext context) async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    print('in Permission');
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
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
