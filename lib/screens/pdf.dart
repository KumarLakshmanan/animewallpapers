import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final File file;
  final String title;
  const PdfViewer({
    Key? key,
    required this.file,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  void initState() {
    super.initState();
  }

  final d = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
        title: Text(widget.title.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await OpenFile.open(widget.file.path);
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        widget.file,
      ),
    );
  }
}
