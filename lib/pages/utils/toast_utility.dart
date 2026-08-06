import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtilityIntranet {
 static void showInfoToast(String message,
      {ToastificationType type = ToastificationType.info,
      VoidCallback? onTap}) {
    toastification.show(
      title: Text(message),
      type: type,
      callbacks: ToastificationCallbacks(
        onTap: onTap != null
            ? (toastItem) {
                onTap();
              }
            : null,
      ),
    );
  }
}
