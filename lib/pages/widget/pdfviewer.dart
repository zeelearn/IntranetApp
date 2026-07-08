import 'dart:io';
import 'package:Intranet/api/response/cvf/QuestionResponse.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../helper/utils.dart';

class MyPdfApp extends StatefulWidget {
  String worksheetUrl;
  String title;
  String module;
  String filename;
  onClickListener listener;
  Allquestion question;

  MyPdfApp(
      {required this.title,
      required this.filename,
      required this.module,
      required this.listener,
      required this.question,
      required this.worksheetUrl});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<MyPdfApp> {
  bool isLoading = true;

  File? mFile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkFile();
  }

  checkFile() async {
    if (widget.module.isEmpty) {
      setState(() {
        isLoading = false;
      });
    } else if (widget.module.isNotEmpty) {
      String dir = (await getTemporaryDirectory()).path;
      String path = '${dir}/${widget.module}/${widget.filename}.pdf';
      if (widget.filename.contains('.pdf')) {
        path = '${dir}/${widget.module}/${widget.filename}';
      }
      if (!await Directory('${dir}/${widget.module}').exists()) {
        Directory myNewDir =
            await Directory('${dir}/${widget.module}').create(recursive: true);
      }
      if (await File(path).exists()) {
        mFile = File(path);
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = true;
        });
        Utility.downloadContent(widget.worksheetUrl, path).then((value) {
          setState(() {
            isLoading = false;
          });
        });
        mFile = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              widget.listener.onClick(ACTION_ADD_NEW_IMAGE, widget.question);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.add,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Utility.showLoader()
          : mFile != null
              ? PdfViewer.file(mFile!.path) /* SfPdfViewer.file(mFile!) */
              : PdfViewer.uri(
                  Uri.parse(widget.worksheetUrl),
                ),
    );
  }
}
