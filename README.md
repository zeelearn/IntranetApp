# intranet

Intranet

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


flutter run -d chrome --web-browser-flag "--disable-web-security"


flutter run -d chrome --web-browser-flag --disable-web-security  --dart-define=IS_STAGING=true   


Value	Base64
IS_STAGING=true	SVNfU1RBR0lORz10cnVl
IS_STAGING=false	SVNfU1RBR0lORz1mYWxzZQ==


sha256_cert_fingerprints

keytool -list -v \
-keystore /Users/sudhir.patil/Development/flutter/AppCode/UAT/IntranetApp/android/zeelearn_android.jks \
-alias zeel


adb shell pm reset-app-links com.zeelearn.intranet



adb shell pm verify-app-links --re-verify com.zeelearn.intranet

adb shell pm get-app-links com.zeelearn.intranet

14002302
140023021