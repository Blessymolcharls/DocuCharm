// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import "dart:html" as html;

void startBrowserDownload({required String url, required String fileName}) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..style.display = "none";

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
