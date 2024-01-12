import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage {
  showWarningToast(String msg, {Color? bgcolor}) {
    Fluttertoast.showToast(msg: msg, backgroundColor: bgcolor ?? Colors.red);
  }

  showSuccessToast(String msg, {Color? bgcolor}) {
    Fluttertoast.showToast(
        msg: msg, backgroundColor: bgcolor ?? Colors.greenAccent);
  }

  showErrorToast(String msg, {Color? bgcolor}) {
    Fluttertoast.showToast(msg: msg, backgroundColor: bgcolor ?? Colors.red);
  }
}
