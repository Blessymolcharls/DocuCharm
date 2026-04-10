import "dart:io";

import "package:flutter/material.dart";
import "package:syncfusion_flutter_pdfviewer/pdfviewer.dart";

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: SfPdfViewer.file(file),
    );
  }
}
