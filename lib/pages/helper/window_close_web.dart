import 'dart:io';

import 'package:get/get.dart';
import 'package:web/web.dart' as html;

import '../auth/login.dart';

void closeAppWindow() {
  Get.offAll(() => LoginPage(isAutoLogin: false,));
  
}