import "package:flutter/material.dart";

enum ToolType {
  merge,
  split,
  imagesToPdf,
  pdfToImages,
  rotate,
}

extension ToolTypeMeta on ToolType {
  String get title {
    switch (this) {
      case ToolType.merge:
        return "Merge PDFs";
      case ToolType.split:
        return "Split PDF";
      case ToolType.imagesToPdf:
        return "Images to PDF";
      case ToolType.pdfToImages:
        return "PDF to Images";
      case ToolType.rotate:
        return "Rotate PDF";
    }
  }

  String get subtitle {
    switch (this) {
      case ToolType.merge:
        return "Combine multiple files into one PDF";
      case ToolType.split:
        return "Break a PDF into one-page PDFs";
      case ToolType.imagesToPdf:
        return "Convert gallery images into a PDF";
      case ToolType.pdfToImages:
        return "Extract each page as an image";
      case ToolType.rotate:
        return "Rotate all pages by 90/180/270";
    }
  }

  IconData get icon {
    switch (this) {
      case ToolType.merge:
        return Icons.join_full;
      case ToolType.split:
        return Icons.call_split;
      case ToolType.imagesToPdf:
        return Icons.image;
      case ToolType.pdfToImages:
        return Icons.collections;
      case ToolType.rotate:
        return Icons.rotate_90_degrees_cw;
    }
  }

  String get endpoint {
    switch (this) {
      case ToolType.merge:
        return "/api/pdf/merge";
      case ToolType.split:
        return "/api/pdf/split";
      case ToolType.imagesToPdf:
        return "/api/pdf/images-to-pdf";
      case ToolType.pdfToImages:
        return "/api/pdf/pdf-to-images";
      case ToolType.rotate:
        return "/api/pdf/rotate";
    }
  }

  bool get allowsMultipleFiles {
    return this == ToolType.merge || this == ToolType.imagesToPdf;
  }

  bool get expectsPdfInput {
    return this != ToolType.imagesToPdf;
  }
}
