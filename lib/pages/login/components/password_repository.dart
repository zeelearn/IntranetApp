import 'package:flutter/cupertino.dart';

class PasswordRepository {
  Future<String> getCurrentPassword() async {
    return 'adminadmin';
  }

  Future<void> changePassword(String password) async {
    debugPrint("Map event =============="+password);
    await Future.delayed(Duration(seconds: 1));
    debugPrint("Map event =============="+password);

  }
}
