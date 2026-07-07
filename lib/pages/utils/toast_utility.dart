import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtilityIntranet {
 static void showInfoToast(String message,
      {ToastificationType type = ToastificationType.info}) {
    toastification.show(
      title: Text(message),
      type: type,
    );
  }
}
