import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class LocationHelper{

  static isLocationPermission(BuildContext context) async{
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    print('in Permission');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      return false;
    }
    return true;
  }
  static getLocation(BuildContext? context) async{
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    print('in Permission');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    print('has Permission ${_permissionGranted}');
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      print('request Permission 12 ${_permissionGranted}');
      if (_permissionGranted == PermissionStatus.deniedForever) {
        print('has Permission always denied');
        if(context!=null)
          Utility.openPermisisonSettings(context!);
      }else if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print('location is ');
    _locationData = await location.getLocation();
    print(_locationData);
    return _locationData;
  }
}