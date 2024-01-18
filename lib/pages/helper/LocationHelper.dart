import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

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

  static getLocation(BuildContext? context) async {
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
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      print('request Permission 12 $permissionGranted');
      if (permissionGranted == PermissionStatus.deniedForever) {
        print('has Permission always denied');
        if (context != null) {
          Utility.openPermisisonSettings(context);
        }
      } else if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print('location is ');
    locationData = await location.getLocation();
    print(locationData);
    return locationData;
  }
}
