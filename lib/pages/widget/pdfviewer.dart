import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../helper/utils.dart';

class MyPdfApp extends StatefulWidget {
  String worksheetUrl;
  String title;
  String module;
  String filename;

  MyPdfApp(
      {required this.title, required this.filename, required this.module, required this.worksheetUrl});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<MyPdfApp> {

  bool isLoading =true;

  File? mFile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkFile();
  }

  checkFile() async {
    if(widget.module.isEmpty){
      setState(() {
        isLoading = false;
      });
    }else {
      String dir = (await getTemporaryDirectory()).path;
      String path = '${dir}/${widget.module}/${widget.filename}.pdf';
      if(!await Directory('${dir}/${widget.module}').exists()){
        Directory myNewDir = await Directory('${dir}/${widget.module}').create(recursive: true);
        print('directory created');
      }
      print('path is ${path}');
      if (await File(path).exists()) {
        mFile = File(path);
        setState(() {
          isLoading = false;
        });
      } else {
        print('download starting...');
        setState(() {
          isLoading = true;
        });
        Utility.downloadContent(widget.worksheetUrl, path).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.worksheetUrl);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading ? Utility.showLoader() : mFile != null
          ? SfPdfViewer.file(mFile!)
          : SfPdfViewer.network(
              widget.worksheetUrl,
            ),
    );
  }
}