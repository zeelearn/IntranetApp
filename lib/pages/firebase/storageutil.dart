import 'dart:io';
import 'dart:isolate';

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
    /*if (null != file) {
      String targetPath = file.path;
      targetPath = targetPath.replaceAll('.jpg', '');
      targetPath = targetPath+'temp.jpg';
      print(targetPath);
      file = File(await compressAndGetFile(file,targetPath));
    }*/
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
          player.files = Uri.encodeFull(imageUrl as String);
          player.files = player.files.replaceAll('&', '___');
          print(player.files);
          response.onUploadSuccess(player);
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