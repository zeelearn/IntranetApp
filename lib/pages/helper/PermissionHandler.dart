import 'package:permission_handler/permission_handler.dart';

class PermissionUtil{

  static requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.notification,
    ].request();
  }
}