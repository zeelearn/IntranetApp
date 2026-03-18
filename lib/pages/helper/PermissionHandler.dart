import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static requestPermission() async {
    if (kIsWeb) {
      await Permission.location.request();
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.notification,
      ].request();
    }
  }
}
