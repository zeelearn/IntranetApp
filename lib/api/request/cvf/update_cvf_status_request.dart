import 'dart:convert';
import 'dart:io';

class UpdateCVFStatusRequest {
  late String PJPCVF_id;
  late String DateTime;
  late String Status;
  late int Employee_id;
  late double Latitude;
  late double Longitude;
  late String Address;
  late double CheckOutLatitude;
  late double CheckOutLongitude;
  late String CheckOutAddress;

  UpdateCVFStatusRequest(
      {
        required this.PJPCVF_id,required this.DateTime,required this.Status,required this.Employee_id,required this.Latitude,required this.Longitude,
        required this.Address, required this.CheckOutLatitude,required this.CheckOutLongitude,required this.CheckOutAddress
      });

  getJson(){
    return jsonEncode( {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
      'Latitude': Latitude,
      'Longitude': Longitude,
      'Address': Address,
      'CheckOutLatitude': CheckOutLatitude,
      'CheckOutLongitude': CheckOutLongitude,
      'CheckOutAddress': CheckOutAddress,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  UpdateCVFStatusRequest.fromJson(Map<String, dynamic> json) {
    PJPCVF_id = json['PJPCVF_id'];
    DateTime = json['DateTime'];
    Status = json['Status'];
    Employee_id = json['Employee_id'];
    Latitude = json['Latitude'];
    Longitude = json['Longitude'];
    Address = json['Address'];
    CheckOutLatitude = json['CheckOutLatitude'];
    CheckOutLongitude = json['CheckOutLongitude'];
    CheckOutAddress = json['CheckOutAddress'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
      'Latitude': Latitude,
      'Longitude': Longitude,
      'Address': Address,
      'CheckOutLatitude': CheckOutLatitude,
      'CheckOutLongitude': CheckOutLongitude,
      'CheckOutAddress': CheckOutAddress,
    };
    return map;
  }
}