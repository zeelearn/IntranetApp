import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:path/path.dart' as Path;

import '../../api/response/cvf/QuestionResponse.dart';
import '../iface/onResponse.dart';
import '../iface/onUploadResponse.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseStorageUtil{
  uploadFile(Allquestion player,String filePath,String fileName,onUploadResponse response)async{
    File file = File(filePath);
    response.onStart();
    String imagePath = "images/cvf/${fileName}.jpg";
// Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

// Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to "mountains.jpg"
    final imageUploadRef = storageRef.child(imagePath);


// Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = imageUploadRef.putFile(file, metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          print("Upload is paused.");
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
        // Handle successful uploads on complete
          dynamic imageUrl= await taskSnapshot.ref.getDownloadURL();
          player.files = imageUrl as String;
          //player.files = player.files.replaceAll('&', '___');
          print('FILEUPLOAD---- ${player.files}');
          response.onUploadSuccess(player);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }

  getContentType(String fileName){
    String contentType = 'image/jpg';
    if (fileName.contains("/jpg")) {
      contentType = 'image/jpg';
    } else if (fileName.contains(".gif")) {
      contentType = 'image/gif';
    } else if (fileName.contains("pdf")) {
      contentType = "application/pdf";
    } else if (fileName.contains("html")) {
      contentType = "text/html";
    } else if (fileName.contains("zip") ) {
      contentType = "application/zip";
      //res.setHeader("Content-Disposition", "attachment; filename=\"" + pictureName + "\"");
    }else if (fileName.contains(".mp3") ) {
      contentType = "application/mp3";
    }else if (fileName.contains(".mp4") ) {
      contentType = "application/mp4";
    }else if (fileName.contains(".xls") ) {
      contentType = "application/xls";
    }else if (fileName.contains(".xls") ) {
      contentType = "application/xls";
    }else if(fileName.contains('.docx')){
      contentType = "application/docx";
    }else if(fileName.contains('.xlsx')){
      contentType = "application/xlsx";
    }else{
      try {
        var extention = fileName.split('.');
        contentType = "application/${extention[1]}";
      }catch(e){}
    }
    return contentType;
  }

  uploadAnyFile(Allquestion player,String filePath,String fileName,onUploadResponse response)async{
    File file = File(filePath);
    response.onStart();
    String imagePath = "files/cvf/${fileName}";
// Create the file metadata
    final metadata = SettableMetadata(contentType: getContentType(fileName));

// Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to "mountains.jpg"
    final imageUploadRef = storageRef.child(imagePath);


// Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = imageUploadRef.putFile(file, metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          print("Upload is paused.");
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
        // Handle successful uploads on complete
          dynamic imageUrl= await taskSnapshot.ref.getDownloadURL();
          player.files = imageUrl as String;
          //player.files = player.files.replaceAll('&', '___');
          print(player.files);
          response.onUploadSuccess(player);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }

  getProfileImage(String employeeId,onUploadResponse response) async {
    final storageRef = FirebaseStorage.instance.ref();
    String imagePath = "images/avtar/${employeeId}.jpg";
    final imageUploadRef = storageRef.child(imagePath);
    imageUploadRef.getData(10000000).then((data) =>
          response.onUploadSuccess(data)).
    catchError((e) =>  print('error'));
  }

  uploadAvtar(String filePath,String employeeId,onUploadResponse response)async{
    File file = File(filePath);
    response.onStart();
    String imagePath = "images/avtar/${employeeId}.jpg";
// Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

// Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to "mountains.jpg"
    final imageUploadRef = storageRef.child(imagePath);


// Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = imageUploadRef.putFile(file, metadata);

// Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          response.onUploadProgress(progress.toInt());
          break;
        case TaskState.paused:
          print("Upload is paused.");
          response.onUploadError('Upload Paused');
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          response.onUploadError('Upload canceled');
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          response.onUploadError('Upload Error');
          break;
        case TaskState.success:
        // Handle successful uploads on complete
          dynamic imageUrl= await taskSnapshot.ref.getDownloadURL();
          imageUrl = Uri.encodeFull(imageUrl as String);
          imageUrl = imageUrl.replaceAll('&', '___');

          print('-----------------------------');
          print(imageUrl);
          response.onUploadSuccess(imageUrl);
          break;
      }
    });

    //await imageUploadRef.getDownloadURL();
  }


  Future<String> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
        minWidth: 800,
        minHeight: 800,
        quality: 100
    );

    print(file.lengthSync());
    //print(result.lengthSync());

    return result!.path;
  }

}