import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:Intranet/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:path/path.dart' as Path;

import '../../api/response/cvf/QuestionResponse.dart';
import '../iface/onResponse.dart';
import '../iface/onUploadResponse.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseStorageUtil {
  // Helper to get the storage reference.
  // Ensure Firebase.initializeApp() is called in your main() function.
  Reference get _storageRef => FirebaseStorage.instance.ref();

  uploadFile(Allquestion player, String filePath, String fileName,
      onUploadResponse response) async {
    response.onStart();
    String imagePath = "images/cvf/${fileName}.jpg";
// Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Create a reference to the file path
    final imageUploadRef = _storageRef.child(imagePath);

// Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = kIsWeb
        ? imageUploadRef.putData(await XFile(filePath).readAsBytes(), metadata)
        : imageUploadRef.putFile(File(filePath), metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          dynamic imageUrl = await taskSnapshot.ref.getDownloadURL();
          player.files = imageUrl as String;
          //player.files = player.files.replaceAll('&', '___');
          response.onUploadSuccess(player);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }

  getContentType(String fileName) {
    String contentType = 'image/jpg';
    if (fileName.contains("/jpg")) {
      contentType = 'image/jpg';
    } else if (fileName.contains(".gif")) {
      contentType = 'image/gif';
    } else if (fileName.contains("pdf")) {
      contentType = "application/pdf";
    } else if (fileName.contains("html")) {
      contentType = "text/html";
    } else if (fileName.contains("zip")) {
      contentType = "application/zip";
      //res.setHeader("Content-Disposition", "attachment; filename=\"" + pictureName + "\"");
    } else if (fileName.contains(".mp3")) {
      contentType = "application/mp3";
    } else if (fileName.contains(".mp4")) {
      contentType = "application/mp4";
    } else if (fileName.contains(".xls")) {
      contentType = "application/xls";
    } else if (fileName.contains(".xls")) {
      contentType = "application/xls";
    } else if (fileName.contains('.docx')) {
      contentType = "application/docx";
    } else if (fileName.contains('.xlsx')) {
      contentType = "application/xlsx";
    } else {
      try {
        var extention = fileName.split('.');
        contentType = "application/${extention[1]}";
      } catch (_) {}
    }
    return contentType;
  }

  uploadAnyFile(Allquestion player, String filePath, String fileName,
      onUploadResponse response,
      {Uint8List? fileBytes}) async {
    response.onStart();
    String imagePath = "files/cvf/${fileName}";
// Create the file metadata
    final metadata = SettableMetadata(contentType: getContentType(fileName));

    // Create a reference to the file path
    final imageUploadRef = _storageRef.child(imagePath);

// Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = kIsWeb
        ? imageUploadRef.putData(
            fileBytes ?? await XFile(filePath).readAsBytes(), metadata)
        : imageUploadRef.putFile(File(filePath), metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          dynamic imageUrl = await taskSnapshot.ref.getDownloadURL();
          player.files = imageUrl as String;
          //player.files = player.files.replaceAll('&', '___');
          response.onUploadSuccess(player);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }

  getProfileImage(String employeeId, onUploadResponse response) async {
    String imagePath = "images/avtar/${employeeId}.jpg";
    final imageUploadRef = _storageRef.child(imagePath);
    imageUploadRef
        .getData(10000000)
        .then((data) => response.onUploadSuccess(data))
        .catchError((_) {});
  }

  uploadAvtar(
      String filePath, String employeeId, onUploadResponse response) async {
    response.onStart();
    String imagePath = "images/avtar/${employeeId}.jpg";
// Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Create a reference to the file path
    final imageUploadRef = _storageRef.child(imagePath);

// Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = kIsWeb
        ? imageUploadRef.putData(await XFile(filePath).readAsBytes(), metadata)
        : imageUploadRef.putFile(File(filePath), metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          dynamic imageUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrl = Uri.encodeFull(imageUrl as String);
          imageUrl = imageUrl.replaceAll('&', '___');

          response.onUploadSuccess(imageUrl);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }

  Future<String> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        minWidth: 800, minHeight: 800, quality: 100);
    return result!.path;
  }
}
